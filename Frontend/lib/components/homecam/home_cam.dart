import 'dart:io';

import 'package:easy_onvif/onvif.dart';
import 'package:flutter/cupertino.dart';
import 'package:loggy/loggy.dart';
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

String profToken_1 = "profile_1";
String profToken_2 = "profile_2";

void main(List<String> arguments) async {
  final config =
      loadYaml(File('camTest/config.sample.yaml').readAsStringSync());

  final onvif = await Onvif.connect(
    host: config['host'],
    username: config['username'],
    password: config['password'],
    logOptions: const LogOptions(
      LogLevel.debug,
      stackTraceLevel: LogLevel.error,
    ),
    printer: const PrettyPrinter(
      showColors: true,
    ),
  );

  var deviceInfo = await onvif.deviceManagement.getDeviceInformation();

  debugPrint('Manufacturer: ${deviceInfo.manufacturer}');
  debugPrint('Model: ${deviceInfo.model}');

  var capabilities = await onvif.deviceManagement.getCapabilities();

  // print(capabilities);

  var hostname = await onvif.deviceManagement.getHostname();

  debugPrint("호스트명: $hostname");

  var networkProtocols = await onvif.deviceManagement.getNetworkProtocols();

  for (var networkProtocol in networkProtocols) {
    debugPrint('${networkProtocol.name} ${networkProtocol.port}');
  }

  var newUsers = <User>[
    User(username: 'test_1', password: 'onvif.device', userLevel: 'User'),
    User(username: 'test_2', password: 'onvif.device', userLevel: 'User')
  ];

  await onvif.deviceManagement.createUsers(newUsers);

  var users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    debugPrint('${user.username} ${user.userLevel}');
  }

  var deleteUsers = ['test_1', 'test_2'];

  await onvif.deviceManagement.deleteUsers(deleteUsers);

  users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    debugPrint('${user.username} ${user.userLevel}');
  }

  var videoSources = await onvif.media.getVideoSources();

  for (var videoSource in videoSources) {
    debugPrint('${videoSource.token} ${videoSource.resolution}');
  }

  var streamUri = await onvif.media.getStreamUri(profToken_1);
  debugPrint(streamUri.uri);
}
