import 'package:reply/reply.dart';
import 'package:test/test.dart';

void main() {
  Recorder<String, String> recorder;

  const int notInfiniteButAlot = 1000;

  setUp(() => recorder = new Recorder<String, String>());

  test('should support a simple request/response', () {
    recorder.given('Hello').reply('Hi there!').once();
    final recording = recorder.toRecording();
    expect(recording.hasRecord('Hello'), isTrue);
    expect(recording.reply('Hello'), 'Hi there!');
    expect(recording.hasRecord('Hello'), isFalse);
    expect(() => recording.reply('Hello'), throwsStateError);
  });

  test('should support emitting a response n times', () {
    recorder.given('Hello').reply('Hi there!').times(2);
    final recording = recorder.toRecording();
    expect(recording.reply('Hello'), 'Hi there!');
    expect(recording.reply('Hello'), 'Hi there!');
    expect(() => recording.reply('Hello'), throwsStateError);
  });

  test('should support emitting a response ∞ times', () {
    recorder.given('Hello').reply('Hi there!').always();
    final recording = recorder.toRecording();
    for (var i = 0; i < notInfiniteButAlot; i++) {
      expect(recording.reply('Hello'), 'Hi there!');
    }
    expect(recording.hasRecord('Hello'), isTrue);
  });
}
