// ignore_for_file: avoid_print

void printW(dynamic text) {
  print('\x1B[33m$text\x1B[0m');
}

void printE(dynamic text) {
  print('\x1B[31m$text\x1B[0m');
}

void printO(dynamic text) {
  print('\x1b[32m$text\x1B[0m');
}

void limparPrint() {
  print("\x1B[2J\x1B[0;0H");
}
