typedef FirestoreFrom<T> = T Function(
  dynamic /* DocumentSnapshot<Map<String, dynamic>> */ doc,
);
typedef FirestoreTo<T> = Map<String, dynamic> Function(T value);

class FirestoreConverter<T> {
  final FirestoreFrom<T> from;
  final FirestoreTo<T> to;
  const FirestoreConverter({required this.from, required this.to});
}
