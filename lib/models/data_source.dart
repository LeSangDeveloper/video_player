import 'package:video_player/enums/data_souce_type.dart';
import 'package:video_player/enums/video_format.dart';

class DataSource {

  final DataSourceType dataSourceType;
  final String? uri;
  final VideoFormat? formatHint;
  final Map<String, String> httpHeaders;
  final String? asset;
  final String? package;

  DataSource(this.dataSourceType, this.uri, this.formatHint, this.httpHeaders, this.asset, this.package);

  DataSourceType getSourceType() {
    return dataSourceType;
  }
}