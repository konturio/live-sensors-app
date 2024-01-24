// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogMessage _$LogMessageFromJson(Map<String, dynamic> json) => LogMessage(
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      message: json['message'] as String,
    );

Map<String, dynamic> _$LogMessageToJson(LogMessage instance) =>
    <String, dynamic>{
      'level': _$LogLevelEnumMap[instance.level]!,
      'message': instance.message,
    };

const _$LogLevelEnumMap = {
  LogLevel.info: 'info',
  LogLevel.error: 'error',
  LogLevel.warning: 'warning',
};
