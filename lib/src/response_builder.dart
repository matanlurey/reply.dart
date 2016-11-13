part of reply;

class _DefaultResponseBuilder<Q, R> implements ResponseBuilder<Q, R> {
  final Recorder<Q, R> _recorder;
  final Q _request;

  _DefaultResponseBuilder(this._recorder, this._request);

  @override
  ConclusionBuilder<Q, R, Recorder<Q, R>> reply(
    R response, {
    void andBranch(Branch<Q, R> branch),
  }) {
    if (andBranch != null) {
      throw new UnimplementedError();
    }
    if (response == null) {
      throw new ArgumentError.notNull('response');
    }
    return new _DefaultConclusionBuilder(
      _recorder,
      _request,
      response,
    );
  }
}
