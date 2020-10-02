



enum ObserverState { INIT, VALUE_CHANGED}

abstract class StateListener {
  void onStateChanged(ObserverState state, String value);
}


//Singleton reusable class
class StateProvider {

  List<StateListener> observers;

  static final StateProvider _instance = new StateProvider.internal();
  factory StateProvider() => _instance;

  StateProvider.internal() {
    observers = new List<StateListener>();
    initState();
  }

  void initState() async {
    notify(ObserverState.INIT, "");
  }

  void subscribe(StateListener listener) {
    observers.add(listener);
  }

  void notify(dynamic state, String value) {
    observers.forEach((StateListener obj) => obj.onStateChanged(state, value));
  }

  void dispose(StateListener thisObserver) {
    for (var obj in observers) {
      if (obj == thisObserver) {
        observers.remove(obj);
      }
    }
  }
}