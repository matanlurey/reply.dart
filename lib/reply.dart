/// Utilities for recording and replaying API interactions.
///
/// Reply is a general use library that can:
/// - Allow programmatic configuration (i.e. stubbing/mocking)
/// - Serve as a more complex state machine
/// - Reusable as a record/replay infrastructure for e2e testing
library reply;

part 'src/conclusion_builder.dart';
part 'src/recorder.dart';
part 'src/recording.dart';
part 'src/response_builder.dart';

/// A configured `request->response` pair.
abstract class Record<Q, R> {
  /// Whether this response should never be removed (always respond).
  bool get always;

  /// When to respond.
  Q get request;

  /// What to respond with.
  R get response;
}

/// Builds pairs of request/response(s).
///
/// Use a recorder to fluently write configuration:
///     recorder
///       .given('Hello')
///       .reply('Hi there!')
///       .record();
///
/// A recorder can be converted to a [Recording] to play back:
///     recorder.toRecording().reply('Hello') // Returns 'Hi there!'
abstract class Recorder<Q, R> {
  /// Create a new empty recorder.
  factory Recorder() => new _DefaultRecorder<Q, R>();

  /// Adds a configured [record].
  ///
  /// Most user implementations should use the [given] builder. This is provided
  /// mostly to allow extensibility/custom recorders in the near future.
  void addRecord(Record<Q, R> record);

  /// Returns a builder that configures what to do when [request] is received.
  ///
  /// If [request] already exists, the response is queued as a future response.
  ResponseBuilder<Q, R> given(Q request);

  /// Returns a collection of all recorded request/response pairs.
  Recording<Q, R> toRecording();
}

abstract class Recording<Q, R> {
  /// Returns whether [request] is recorded.
  bool hasRecord(Q request);

  /// Resolves and returns a response for [request].
  ///
  /// If not found throws [StateError].
  R reply(Q request);
}

abstract class ResponseBuilder<Q, R> {
  /// Records [response] to the previous request.
  ///
  /// If [andBranch] is set then calls with a [Branch] to change configuration.
  ///
  /// Can be used to build dependent responses (to mimic business logic):
  ///     recorder
  ///       .given('Hello')
  ///       .reply('Hi there', andBranch: (branch) {
  ///         branch
  ///           .reply('I already said hi...')
  ///           .always();
  ///       })
  ///       .record();
  ///
  /// Output after branching:
  ///     var recording = recorder.toRecording();
  ///     recorder.reply('Hello'); // Hi there!
  ///     recorder.reply('Hello'); // I already said hi...
  ///     recorder.reply('Hello'); // I already said hi...
  ConclusionBuilder<Q, R, Recorder<Q, R>> reply(
    R response, {
    void andBranch(Branch<Q, R> branch),
  });
}

abstract class Branch<Q, R> implements Recorder<Q, R> {
  /// Removes all responses recorded for [request].
  ///
  /// If no response is recorded, throws [StateError].
  Branch<Q, R> remove(Q request);

  /// Replaces all requests recorder for [request] with [response].
  ///
  /// If no response is recorded, throws [StateError].
  ConclusionBuilder<Q, R, Branch<Q, R>> replace(Q request, R response);
}

abstract class ConclusionBuilder<Q, R, T extends Recorder<Q, R>> {
  /// Records the `request->response` to _always_ return (indefinitely).
  ///
  /// Returns back the original [Reorder].
  T always();

  /// Records the `request->response` queued to return once.
  ///
  /// Returns back the original [Recorder].
  T once();

  /// Returns the `request->response` queued to return [times].
  ///
  /// Returns back the original [Recorder].
  T times(int times);
}
