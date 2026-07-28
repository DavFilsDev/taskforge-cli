interface class Repository<T> {
  Future<List<T>> getAll() => throw UnimplementedError();

  Future<T?> getById(String id) => throw UnimplementedError();

  Future<void> add(T item) => throw UnimplementedError();

  Future<void> update(T item) => throw UnimplementedError();

  Future<void> deleteById(String id) => throw UnimplementedError();
}
