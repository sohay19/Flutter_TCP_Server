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

  String _message = '';
  Function? showMessage;


  SocketController() {
    _myInfo = new AddressInfo();
  }

  setNetworkInfo() async {
    try {
      ConnectivityResult connectivityResult = await _connectivify.checkConnectivity();
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
          _message += '>> Receive\n';
          _message += '${receiveMsg}\n';
          //
          _endProcess();
          final list = receiveMsg.split(' ');
          final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
          if (operator != OperatorType.SEARCH) {
            return;
          }
          final String sendMsg = '${_myInfo.ip} ${Static.TCP_PORT}';
          _udpSocket.send(utf8.encode(sendMsg), InternetAddress(list[1]), int.parse(list.last));
          _message += '>> Send\n';
          _message += '${sendMsg}\n';
          //
          _endProcess();
        }
      });
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 48) {
        _message += 'Already Opened\n';
        _endProcess();
      }
    } catch (e) {
      throw ErrorType.BIND;
    }
  }

  _bindTCPServer() async {
    try {
      _tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, Static.TCP_PORT, shared: true);
      _message += 'Open Server\n';
      _endProcess();
      _tcpSocket.listen(_listenTCPServer);
    } catch (e) {
      throw ErrorType.BIND;
    }
  }

  _listenTCPServer(Socket clientSocket) {
    try {
      final String sendMsg = 'SUCCESS_CONNECTION!';
      clientSocket.add(utf8.encode(sendMsg));
      _message += '>> Receive\n';
      _message += 'CONNECT\n\n';
      _message += '>> Send\n';
      _message += '${sendMsg}\n';
      _endProcess();
      //
      clientSocket.listen((data) {
        final String receiveMsg = String.fromCharCodes(data);
        _message += '>> Receive\n';
        _message += '${receiveMsg}\n\n';
        final list = receiveMsg.split(' ');
        final operator = OperatorType.values.firstWhere((element) => element.msg == list.first);
        switch(operator) {
          case OperatorType.GETINT:
            final String sendMsg = '${operator.msg} 8';
            clientSocket.add(utf8.encode(sendMsg));
            _message += '>> Send\n';
            _message += '${sendMsg}\n';
            break;
          case OperatorType.GETSTRING:
            final String sendMsg = '${operator.msg} practice';
            clientSocket.add(utf8.encode(sendMsg));
            _message += '>> Send\n';
            _message += '${sendMsg}\n';
            break;
          default:
            break;
        }
        _endProcess();
      });
    } catch (e) {
      throw ErrorType.SEND;
    }
  }

  closeServer() {
    _udpSocket.close();
    _tcpSocket.close();
    _message += 'Close Server\n';
    _endProcess();
  }

  _endProcess() {
    showMessage?.call(_message);
    _message = '';
  }
}