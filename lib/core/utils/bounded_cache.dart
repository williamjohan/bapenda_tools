class BoundedCache<K, V> {
  final int maxEntries;
  final _map = <K, V>{}; // LinkedHashMap → urutan insert terjaga

  BoundedCache({this.maxEntries = 60});

  V? get(K key) {
    final value = _map.remove(key);
    if (value == null) return null;
    _map[key] = value; // pindah ke belakang = most recently used
    return value;
  }

  void set(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    if (_map.length > maxEntries) {
      _map.remove(_map.keys.first); // buang yang paling lama gak dipake
    }
  }
}
