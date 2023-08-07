class ErrorWithMessage extends Error {
  String message;
  ErrorWithMessage(this.message);
}

class SimpleState<S> {
  final List<Function> _listeners = <Function>[];
  late S state;

  SimpleState() {
    state = initState();
  }

  S initState() {
    return state;
  }

  setState(update) {
    update();
    _notify();
  }

  _notify() {
    for (final listener in _listeners) {
      listener(state);
    }
  }

  Function subscribe(void Function(S) listener) {
    _listeners.add(listener);
    Future(() => listener(state));
    return () {
      _listeners.remove(listener);
    };
  }
}
