void main() {
  double Function() f = () => null as dynamic;
  try {
    f();
  } catch (e) {
    print(e);
  }
}
