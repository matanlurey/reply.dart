part of reply;

class _DefaultRecording<Q, R> implements Recording<Q, R> {
  final List<Record<Q, R>> _records;
  final Equality<Q> _requestEquality;

  _DefaultRecording(
    Iterable<Record<Q, R>> records, {
    Equality<Q> requestEquality: const IdentityEquality(),
  })
      : _records = records.toList(),
        _requestEquality = requestEquality {
    assert(_requestEquality != null);
  }

  @override
  bool hasRecord(Q request) {
    return _records.any((r) => _requestEquality.equals(request, r.request));
  }

  @override
  R reply(Q request) {
    for (var i = 0; i < _records.length; i++) {
      if (_requestEquality.equals(_records[i].request, request)) {
        return _replyAt(i);
      }
    }
    throw new StateError('No record found for $request.');
  }

  R _replyAt(int index) {
    final record = _records[index];
    if (!record.always) {
      _records.removeAt(index);
    }
    return record.response;
  }

  @override
  toJsonEncodable({
    encodeRequest(Q request),
    encodeResponse(R response),
  }) => _records.map((record) {
    return {
      'always': record.always,
      'request': encodeRequest(record.request),
      'response': encodeResponse(record.response),
    };
  }).toList();
}
