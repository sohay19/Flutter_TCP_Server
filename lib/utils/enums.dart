enum ErrorType {
  NO_SUPPORT_PLATFORM,
  NO_NETWORK,
  BIND,
  SEND,
}

enum OperatorType {
  SEARCH('search');

  final String msg;
  const OperatorType(this.msg);
}