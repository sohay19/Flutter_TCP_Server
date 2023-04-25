import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../model/address_info.dart';
import '../utils/enums.dart';
import '../utils/statc_value.dart';


class SocketController {
  final Connectivity _connectivify = Connectivity();

  late RawDatagramSocket _udpSocket;
  late ServerSocket _tcpSocket;
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
    _bindUDPServer();
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
    _bindUDPServer();
  }

  _bindUDPServer() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Static.UDP_PORT).then((value) {
        _bindTCPServer();
        return value;
      });
      _udpSocket.listen((event) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram != null) {
          final String receiveMsg = String.fromCharCodes(datagram.data);
          print('===== Broadcast =====');
          print(receiveMsg);
          final list = receiveMsg.split(' ');
          final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
          if (operator != OperatorType.SEARCH) {
            return;
          }
          final String sendMsg = '${_myInfo.ip} ${Static.TCP_PORT}';
          _udpSocket.send(utf8.encode(sendMsg), InternetAddress(list[1]), int.parse(list.last));
        }
      });
    } catch (e) {
      print(e);
      throw ErrorType.BIND;
    }
  }

  _bindTCPServer() async {
    try {
      _tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, Static.TCP_PORT, shared: true);
      _tcpSocket.listen(_listenTCPServer);
    } catch (e) {
      print(e);
      throw ErrorType.BIND;
    }
  }

  _listenTCPServer(Socket clientSocket) {
    try {
      final String sendMsg = 'SUCCESS CONNECTION!';
      clientSocket.add(utf8.encode(sendMsg));
      //
      clientSocket.listen((data) {
        final String receiveMsg = String.fromCharCodes(data);
        print('===== receiveMsg =====');
        final list = receiveMsg.split(' ');
        final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
        switch(operator) {
          default:
            final String sendMsg = '';
            clientSocket.add(utf8.encode(sendMsg));
            break;
        }
      });
    } catch (e) {
      throw ErrorType.SEND;
    }
  }
}