package com.example.video_player;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.FlutterInjector;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;

/** VideoPlayerPlugin */
public class VideoPlayerPlugin implements FlutterPlugin, Messages.AndroidVideoPlayerApi {
  private FlutterState flutterState;
  private final static String TAG = "VideoPlayerPlugin";

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

  @Override
  public void initialize() {

  }

  @NonNull
  @Override
  public Messages.TextureMessage create(@NonNull Messages.CreateMessage msg) {
    return null;
  }

  @Override
  public void dispose(@NonNull Messages.TextureMessage msg) {

  }

  @Override
  public void setLooping(@NonNull Messages.LoopingMessage msg) {

  }

  @Override
  public void setVolume(@NonNull Messages.VolumeMessage msg) {

  }

  @Override
  public void setPlaybackSpeed(@NonNull Messages.PlaybackSpeedMessage msg) {

  }

  @Override
  public void play(@NonNull Messages.TextureMessage msg) {

  }

  @NonNull
  @Override
  public Messages.PositionMessage position(@NonNull Messages.TextureMessage msg) {
    return null;
  }

  @NonNull
  @Override
  public byte[] getFrame(@NonNull Messages.PositionMessage msg) {
    return new byte[0];
  }

  @Override
  public void seekTo(@NonNull Messages.PositionMessage msg) {

  }

  @Override
  public void pause(@NonNull Messages.TextureMessage msg) {

  }

  @Override
  public void setMixWithOthers(@NonNull Messages.MixWithOthersMessage msg) {

  }

  private interface KeyForAssetFn {
    String  get ( String  asset );
  }

  private interface KeyForAssetAndPackageName {
    String get(String asset, String packageName);
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
