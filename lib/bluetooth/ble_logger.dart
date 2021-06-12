class BleLogger {
  List<String> _logMessages = [];

  List<String> get mesages => _logMessages;

  void addToLog(String msg) {
    final DateTime now = DateTime.now();
    String message = '${now.hour}:${now.minute}:${now.second} - $msg';
    _logMessages.add(message);
    print(message);
  }

  void clearLogs() {
    _logMessages.clear();
  }
}
