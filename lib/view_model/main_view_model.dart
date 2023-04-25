
import '../controller/socket_controller.dart';


class MainViewModel {
  late SocketController _socketController;

  String message = '';
  Function? notify;


  MainViewModel() {
    _socketController = new SocketController();
    _socketController.showMessage = _getMessage;
  }

  _getMessage(String msg) {
    message += '${msg}\n';
    notify?.call();
  }

  clearMessage() {
    message = '';
    notify?.call();
  }

  openServer() {
    _socketController.setNetworkInfo();
  }

  closeServer() {
    _socketController.closeServer();
  }
}