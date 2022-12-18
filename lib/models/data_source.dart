import 'package:video_player/enums/data_souce_type.dart';
import 'package:video_player/enums/video_format.dart';

class DataSource {

  final DataSourceType sourceType;
  final String? uri;
  final VideoFormat? formatHint;
  final Map<String, String> httpHeaders;
  final String? asset;
  final String? package;

  DataSource({
    required this.sourceType,
    this.uri,
    this.formatHint,
    this.httpHeaders = const <String, String>{},
    this.asset,
    this.package
  });

  DataSourceType getSourceType() {
    return sourceType;
  }
}