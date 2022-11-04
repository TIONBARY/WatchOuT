class IsCheck {
  IsCheck._();
  static final instance = IsCheck._();

  bool check = false;

  void initCheck() {
    check = false;
  }

  void confirmCheck() {
    check = true;
  }
}
