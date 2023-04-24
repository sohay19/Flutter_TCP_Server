import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tcp_server/model/address_info.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../utils/enums.dart';
import '../utils/statc_value.dart';


class SocketController {
  final Connectivity _connectivify = Connectivity();

  late ServerSocket udpSocket;
  late ServerSocket tcpSocket;
  late AddressInfo _myInfo;


  SocketController() {
    _myInfo = new AddressInfo();
  }

  setNetworkInfo() async {
    try {
      ConnectivityResult connectivityResult = await _connectivify.checkConnectivity();
      //
      if (Platform.isIOS || Platform.isAndroid) {
        if (connectivityResult == ConnectivityResult.wifi) {
          await _getWifiInfo();
        } else {
          throw ErrorType.NO_NETWORK;
        }
      } else if (Platform.isWindows || Platform.isMacOS) {
        if (connectivityResult == ConnectivityResult.ethernet) {
          await _getEthernetInfo();
        } else if (connectivityResult == ConnectivityResult.wifi) {
          await _getWifiInfo();
        } else {
          throw ErrorType.NO_NETWORK;
        }
      }
    } catch(e) {
      throw ErrorType.NO_SUPPORT_PLATFORM;
    }
  }

  _getWifiInfo() async {
    String ip = '';

    final info = NetworkInfo();
    ip = await info.getWifiIP() ?? "";

    _myInfo.ip = ip;
    _myInfo.port = Static.UDP_PORT;

    _bindUDPServer();
    _bindTCPServer();
  }

  _getEthernetInfo() async {
    String ip = '';

    for(var interface in await NetworkInterface.list()) {
      for(var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          ip = addr.address;
        }
      }
    }
    _myInfo.ip = ip;
    _myInfo.port = Static.UDP_PORT;

    _bindUDPServer();
    _bindTCPServer();
  }

  _bindUDPServer() async {
    try {
      udpSocket = await ServerSocket.bind(InternetAddressType.IPv4, Static.UDP_PORT);
      udpSocket.listen(_listenUDPServer);
    } catch (e) {
      throw ErrorType.BIND;
    }
  }

  _bindTCPServer() async {
    try {
      udpSocket = await ServerSocket.bind(InternetAddressType.IPv4, Static.TCP_PORT);
      udpSocket.listen(_listenTCPServer);
    } catch (e) {
      throw ErrorType.BIND;
    }
  }

  _listenUDPServer(Socket clientSocket) {
    try {
      clientSocket.listen((data) {
        final String receiveMsg = String.fromCharCodes(data);
        final list = receiveMsg.split(' ');
        final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
        if (operator != OperatorType.SEARCH) {
          return;
        }
        final String sendMsg = '${_myInfo.ip} ${Static.TCP_PORT}';
        clientSocket.add(utf8.encode(sendMsg));
      });
    } catch (e) {
      throw ErrorType.SEND;
    }
  }

  _listenTCPServer(Socket clientSocket) {
    try {
      clientSocket.listen((data) {
        final String receiveMsg = String.fromCharCodes(data);
        final list = receiveMsg.split(' ');
        final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
        switch(operator) {
          case OperatorType.CONNECT:
            final String sendMsg = 'SUCCESS CONNECTION!';
            clientSocket.add(utf8.encode(sendMsg));
            break;
          default:
            break;
        }
      });
    } catch (e) {
      throw ErrorType.SEND;
    }
  }
}