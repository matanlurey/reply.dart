part of reply;

class _DefaultRecording<Q, R> implements Recording<Q, R> {
  final List<Record<Q, R>> _recordings;

  _DefaultRecording(this._recordings);

  @override
  bool hasRecord(Q request) {
    return _recordings.any((r) => r.request == request);
  }

  @override
  R reply(Q request) {
    for (var i = 0; i < _recordings.length; i++) {
      if (_recordings[i].request == request) {
        return _replyAt(i);
      }
    }
    throw new StateError('No record found for $request.');
  }

  R _replyAt(int index) {
    final record = _recordings[index];
    if (!record.always) {
      _recordings.removeAt(index);
    }
    return record.response;
  }
}
