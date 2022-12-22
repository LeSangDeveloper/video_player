package com.example.video_player;

import android.content.Context;
import android.media.MediaDataSource;
import android.net.Uri;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.PlaybackException;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Player.Listener;
import com.google.android.exoplayer2.audio.AudioAttributes;
import com.google.android.exoplayer2.source.BaseMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.ProgressiveMediaSource;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource;
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSource;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.util.Util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

public class VideoPlayer {
    private static final String FORMAT_SS = "ss";
    private static final String FORMAT_DASH = "dash";
    private static final String FORMAT_HLS = "hls";
    private static final String FORMAT_OTHER = "other";

    private ExoPlayer exoPlayer;

    private Surface surface;

    private final TextureRegistry.SurfaceTextureEntry textureEntry;

    private QueuingEventSink eventSink;

    private final EventChannel eventChannel;

    @VisibleForTesting
    boolean isInitialized = false;

    private final VideoPlayerOptions options;


    public VideoPlayer(Context context,
                       EventChannel eventChannel,
                       TextureRegistry.SurfaceTextureEntry textureEntry,
                       String dataSource,
                       String formatHint,
                       @NonNull Map<String, String> httpHeaders,
                       VideoPlayerOptions options) {
        this.eventChannel = eventChannel;
        this.textureEntry = textureEntry;
        this.options = options;

        ExoPlayer exoPlayer = new ExoPlayer.Builder(context).build();

        Uri uri = Uri.parse(dataSource);
        DataSource.Factory datasourceFactory;

        if (isHTTP(uri)) {
            DefaultHttpDataSource.Factory httpDatasourceFactory = new DefaultHttpDataSource.Factory().setUserAgent("ExoPlayer").setAllowCrossProtocolRedirects(true);

            if (httpHeaders != null && !httpHeaders.isEmpty()) {
                httpDatasourceFactory.setDefaultRequestProperties(httpHeaders);
            }
            datasourceFactory = httpDatasourceFactory;
        } else {
            datasourceFactory = new DefaultDataSource.Factory(context);
        }

        BaseMediaSource mediaDataSource = buildMediaSource(uri, datasourceFactory, formatHint, context);

        exoPlayer.setMediaSource(mediaDataSource);
        exoPlayer.prepare();

        setUpVideoPlayer(exoPlayer, new QueuingEventSink());
    }

    VideoPlayer(ExoPlayer exoPlayer, EventChannel channel, TextureRegistry.SurfaceTextureEntry textureEntry, VideoPlayerOptions options, QueuingEventSink eventSink) {
        this.eventChannel = channel;
        this.textureEntry = textureEntry;
        this.options = options;
        setUpVideoPlayer(exoPlayer, eventSink);
    }

    private static boolean isHTTP(Uri uri) {
        if (uri == null || uri.getScheme() == null) {
            return false;
        }
        String scheme = uri.getScheme();
        return scheme.equals("http") || scheme.equals("https");
    }

    void play() {
        exoPlayer.setPlayWhenReady(true);
    }

    void pause() {
        exoPlayer.setPlayWhenReady(false);
    }

    void setLooping(boolean value) {
        exoPlayer.setRepeatMode(value ? Player.REPEAT_MODE_ALL : Player.REPEAT_MODE_OFF);
    }
    void setPlaybackSpeed(double value) {
        final PlaybackParameters playbackParameters = new PlaybackParameters((float) value);

        exoPlayer.setPlaybackParameters(playbackParameters);
    }

    void setVolume(double value) {
        float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
        exoPlayer.setVolume(bracketedValue);
    }

    void seekTo(int location) {
        exoPlayer.seekTo(location);
    }

    long getPosition() {
        return exoPlayer.getContentPosition();
    }

    void setUpVideoPlayer(ExoPlayer exoPlayer, QueuingEventSink eventSink) {
        this.exoPlayer = exoPlayer;
        this.eventSink = eventSink;

        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        eventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        eventSink.setDelegate(null);
                    }
                });

        surface = new Surface(textureEntry.surfaceTexture());
        exoPlayer.setVideoSurface(surface);
        setAudioAttributes(exoPlayer, options.mixWithOthers);

        exoPlayer.addListener(new Listener() {
            private boolean isBuffering = false;

            public void setBuffering(boolean buffering) {
                if (isBuffering != buffering) {
                    isBuffering = buffering;
                    Map<String, Object> event = new HashMap<>();
                    event.put("event", isBuffering ? "bufferingStart" : "bufferingEnd");
                    eventSink.success(event);
                }
            }

            @Override
            public void onPlaybackStateChanged(int playbackState) {
                if (playbackState == Player.STATE_BUFFERING) {
                    setBuffering(true);
                    sendBufferingUpdate();
                } else if (playbackState == Player.STATE_READY) {
                    if (!isInitialized) {
                        isInitialized = true;
                        sendInitialized();
                    }
                } else if (playbackState == Player.STATE_ENDED) {
                    Map<String, Object> event = new HashMap<>();
                    event.put("event", "completed");
                    eventSink.success(event);
                }

                if (playbackState != Player.STATE_BUFFERING) {
                    setBuffering(false);
                }
            }

            @Override
            public void onPlayerError(PlaybackException error) {
                setBuffering(false);
                if (eventSink != null) {
                    eventSink.error("VideoError", "Video player had error " + error, null);
                }
            }
        });
    }

    private void setAudioAttributes(ExoPlayer player, boolean mixinWithOthers) {
        player.setAudioAttributes(new AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(), !mixinWithOthers);
    }

    private BaseMediaSource buildMediaSource(Uri uri, DataSource.Factory datasourceFactory, String formatHint, Context context) {
        int type;
        if (formatHint == null) {
            type = Util.inferContentType(uri);
        } else {
            switch (formatHint) {
                case FORMAT_SS:
                    type = C.CONTENT_TYPE_SS;
                    break;
                case FORMAT_DASH:
                    type = C.CONTENT_TYPE_DASH;
                    break;
                case FORMAT_HLS:
                    type = C.CONTENT_TYPE_HLS;
                    break;
                case FORMAT_OTHER:
                    type = C.CONTENT_TYPE_OTHER;
                    break;
                default:
                    type = -1;
                    break;
            }
        }

        switch (type) {
            case C.CONTENT_TYPE_SS:
                return new SsMediaSource.Factory(
                        new DefaultSsChunkSource.Factory(datasourceFactory),
                        new DefaultDataSource.Factory(context, datasourceFactory)
                ).createMediaSource(MediaItem.fromUri(uri));
            case C.CONTENT_TYPE_DASH:
                return new DashMediaSource.Factory(
                        new DefaultDashChunkSource.Factory(datasourceFactory),
                        new DefaultDataSource.Factory(context, datasourceFactory)
                ).createMediaSource(MediaItem.fromUri(uri));
            case C.CONTENT_TYPE_HLS:
                return new HlsMediaSource.Factory(datasourceFactory)
                        .createMediaSource(MediaItem.fromUri(uri));
            case C.CONTENT_TYPE_OTHER:
                return new ProgressiveMediaSource.Factory(datasourceFactory)
                        .createMediaSource(MediaItem.fromUri(uri));
            default:
                throw new IllegalStateException("Unsupported type: " + type);
        }
    }

    void sendInitialized() {
        if (isInitialized) {
            Map<String, Object> event = new HashMap<>();
            event.put("event", "initialized");
            event.put("duration", exoPlayer.getDuration());

            if (exoPlayer.getVideoFormat() != null) {
                Format videoFormat = exoPlayer.getVideoFormat();
                int width = videoFormat.width;
                int height = videoFormat.height;
                int rotationDegrees = videoFormat.rotationDegrees;

                if (rotationDegrees == 90 || rotationDegrees == 270) {
                    width = exoPlayer.getVideoFormat().height;
                    height = exoPlayer.getVideoFormat().width;
                }
                event.put("width", width);
                event.put("height", height);

                if (rotationDegrees == 180) {
                    event.put("rotationCorrection", rotationDegrees);
                }
            }

            eventSink.success(event);
        }
    }

    void sendBufferingUpdate() {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "bufferingUpdate");
        List<? extends Number> range = Arrays.asList(0, exoPlayer.getBufferedPosition());
        event.put("values", Collections.singletonList(range));
        eventSink.success(event);
    }

    void dispose() {
        if (isInitialized) {
            exoPlayer.stop();
        }
        textureEntry.release();
        eventChannel.setStreamHandler(null);
        if (surface != null) {
            surface.release();
        }
        if (exoPlayer != null) {
            exoPlayer.release();
        }
    }
}
