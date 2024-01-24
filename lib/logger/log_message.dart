import 'package:json_annotation/json_annotation.dart';
part 'log_message.g.dart';

enum LogLevel {
  @JsonValue("info")
  info,

  @JsonValue("error")
  error,

  @JsonValue("warning")
  warning
}

@JsonSerializable(explicitToJson: true)
class LogMessage {
  final LogLevel level;
  final String message;

  LogMessage({
    required this.level,
    required this.message,
  });

  factory LogMessage.fromJson(Map<String, dynamic> json) =>
      _$LogMessageFromJson(json);
  Map<String, dynamic> toJson() => _$LogMessageToJson(this);
}
