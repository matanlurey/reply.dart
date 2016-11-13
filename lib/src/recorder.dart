part of reply;

class _DefaultRecorder<Q, R> implements Recorder<Q, R> {
  final List<Record<Q, R>> _records = <Record<Q, R>> [];

  @override
  void addRecord(Record<Q, R> record) {
    _records.add(record);
  }

  @override
  ResponseBuilder<Q, R> given(Q request) {
    if (request == null) {
      throw new ArgumentError.notNull('request');
    }
    return new _DefaultResponseBuilder(this, request);
  }

  @override
  Recording<Q, R> toRecording() => new _DefaultRecording(_records.toList());
}
