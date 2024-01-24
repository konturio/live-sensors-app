import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:live_sensors/logger/log_message.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MQTTTransport {
  final port = 1883;
  final mqttEndpoint = 'zigzag.kontur.io';
  final topic = 'live-sensor-logs';
  late MqttServerClient client;
  final ListQueue<LogMessage> pendingMessages = ListQueue();

  Future init(String clientId) async {
    // Create the client
    client = MqttServerClient.withPort(mqttEndpoint, clientId, port);

    // Setup client
    client.secure = false;
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    client.logging(on: true);
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;

    final connMess = MqttConnectMessage() //
        .withClientIdentifier(clientId)
        .startClean();

    client.connectionMessage = connMess;

    // Connect the client
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('MQTT::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('MQTT::socket exception - $e');
      client.disconnect();
    } on Exception catch (e) {
      print('MQT::unknown exception - $e');
      client.disconnect();
    }
  }

  _onDisconnected() {
    final isSolicited = client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited;

    if (!isSolicited) {
      print('MQT::INFO - connection lost');
    }
  }

  _onConnected() {
    pendingMessages.forEach((element) {
      LogMessage msg = pendingMessages.removeFirst();
      _publish(msg);
    });
  }

  send(LogMessage msg) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      _publish(msg);
    } else {
      pendingMessages.add(msg);
    }
  }

  _publish(LogMessage msg) {
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(msg));

    /// Publish it
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }
}
