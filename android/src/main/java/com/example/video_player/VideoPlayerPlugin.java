package com.example.video_player;

import android.content.Context;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;

import io.flutter.FlutterInjector;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;

import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.PlaybackException;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Player.Listener;
import com.google.android.exoplayer2.audio.AudioAttributes;
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

import java.util.Map;

/** VideoPlayerPlugin */
public class VideoPlayerPlugin implements FlutterPlugin, Messages.AndroidVideoPlayerApi {
  private FlutterState flutterState;
  private final static String TAG = "VideoPlayerPlugin";
  private final LongSparseArray<VideoPlayer> videoPlayers = new LongSparseArray<>();
  private VideoPlayerOptions options = new VideoPlayerOptions();

  public VideoPlayerPlugin() {}

  @SuppressWarnings("deprecation")
  private VideoPlayerPlugin(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    this.flutterState =
            new FlutterState(
                    registrar.context(),
                    registrar.messenger(),
                    registrar::lookupKeyForAsset,
                    registrar::lookupKeyForAsset,
                    registrar.textures());
    flutterState.startListening(this, registrar.messenger());
  }

  /** Registers this with the stable v1 embedding. Will not respond to lifecycle events. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final VideoPlayerPlugin plugin = new VideoPlayerPlugin(registrar);
    registrar.addViewDestroyListener(
            view -> {
              plugin.onDestroy();
              return false; // We are not interested in assuming ownership of the NativeView.
            });
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    final FlutterInjector injector = FlutterInjector.instance();
    this.flutterState = new FlutterState(
            binding.getApplicationContext(),
            binding.getBinaryMessenger(),
            injector.flutterLoader()::getLookupKeyForAsset,
            injector.flutterLoader()::getLookupKeyForAsset,
            binding.getTextureRegistry());
    flutterState.startListening(this, binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (flutterState == null) {
      Log.wtf(TAG, "Detached from the engine before registering to it.");
    }
    flutterState.stopListening(binding.getBinaryMessenger());
    flutterState = null;
    initialize();
  }

  @NonNull
  @Override
  public Messages.TextureMessage create(@NonNull Messages.CreateMessage arg) {
    TextureRegistry.SurfaceTextureEntry handle =
            flutterState.textureRegistry.createSurfaceTexture();
    EventChannel eventChannel =
            new EventChannel(
                    flutterState.binaryMessenger, "flutter.io/videoPlayer/videoEvents" + handle.id());

    VideoPlayer player;
    if (arg.getAsset() != null) {
      String assetLookupKey;
      if (arg.getPackageName() != null) {
        assetLookupKey = flutterState.keyForAssetAndPackageName.get(arg.getAsset(), arg.getPackageName());
      } else {
        assetLookupKey = flutterState.keyForAsset.get(arg.getAsset());
      }
      player = new VideoPlayer(flutterState.applicationContext, eventChannel, handle, "asset:///" + assetLookupKey, null, null, options);

    } else {
      @SuppressWarnings("unchecked")
      Map<String, String> httpHeaders = arg.getHttpHeaders();
      player = new VideoPlayer(flutterState.applicationContext, eventChannel, handle, arg.getUri(), arg.getFormatHint(), httpHeaders, options);
    }
    videoPlayers.put(handle.id(), player);

    Messages.TextureMessage textureMessage = new Messages.TextureMessage.Builder().setTextureId(handle.id()).build();
    return textureMessage;
  }

  @Override
  public void dispose(@NonNull Messages.TextureMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.dispose();
    videoPlayers.remove(msg.getTextureId());
  }

  @Override
  public void setLooping(@NonNull Messages.LoopingMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.setLooping(msg.getIsLooping());
  }

  @Override
  public void setVolume(@NonNull Messages.VolumeMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.setVolume(msg.getVolume());
  }

  @Override
  public void setPlaybackSpeed(@NonNull Messages.PlaybackSpeedMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.setPlaybackSpeed(msg.getSpeed());
  }

  @Override
  public void play(@NonNull Messages.TextureMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.play();
  }

  @NonNull
  @Override
  public Messages.PositionMessage position(@NonNull Messages.TextureMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    Messages.PositionMessage result = new Messages.PositionMessage.Builder().setPosition(player.getPosition()).setTextureId(msg.getTextureId()).build();
    player.sendBufferingUpdate();
    return result;
  }

  @NonNull
  @Override
  public byte[] getFrame(@NonNull Messages.PositionMessage msg) {
    return new byte[0];
  }

  @Override
  public void seekTo(@NonNull Messages.PositionMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.seekTo(msg.getPosition().intValue());
  }

  @Override
  public void pause(@NonNull Messages.TextureMessage msg) {
    VideoPlayer player = videoPlayers.get(msg.getTextureId());
    player.pause();
  }

  @Override
  public void setMixWithOthers(@NonNull Messages.MixWithOthersMessage msg) {
    options.mixWithOthers = msg.getMixWithOthers();
  }

  @Override
  public void initialize() {
    disposeAllPlayers();
  }

  private void onDestroy() {
    disposeAllPlayers();
  }

  private interface KeyForAssetFn {
    String  get ( String  asset );
  }

  private interface KeyForAssetAndPackageName {
    String get(String asset, String packageName);
  }


  private void disposeAllPlayers() {
    for (int  i = 0; i < videoPlayers.size(); ++i) {
      videoPlayers.valueAt(i).dispose();
    }
    videoPlayers.clear();
  }

  private static final class FlutterState {
    private final Context applicationContext;
    private final BinaryMessenger binaryMessenger;
    private final KeyForAssetFn keyForAsset;
    private final KeyForAssetAndPackageName keyForAssetAndPackageName;
    private final TextureRegistry textureRegistry;


    private FlutterState(Context applicationContext, BinaryMessenger binaryMessenger, KeyForAssetFn keyForAsset, KeyForAssetAndPackageName keyForAssetAndPackageName, TextureRegistry textureRegistry) {
      this.applicationContext = applicationContext;
      this.binaryMessenger = binaryMessenger;
      this.keyForAsset = keyForAsset;
      this.keyForAssetAndPackageName = keyForAssetAndPackageName;
      this.textureRegistry = textureRegistry;
    }

    void startListening(VideoPlayerPlugin methodHandler, BinaryMessenger messenger) {
      Messages.AndroidVideoPlayerApi.setup(messenger, methodHandler);
    }

    void stopListening(BinaryMessenger messenger) {
      Messages.AndroidVideoPlayerApi.setup(messenger, null);
    }

  }
}
