import 'package:test/test.dart';
import 'dart:convert';
import '../lib/ska_connect.dart';

var errorString = '''
{
  "code": "unavailable",
  "message": "overloaded: back off and retry",
  "details": [
    {
      "type": "google.rpc.RetryInfo",
      "value": "CgIIPA",
      "debug": {"retryDelay": "30s"}
    }
  ]
}
''';

var errorWithoutDetails = '''
{
  "code":"unknown",
  "message":"an unknown error has occurred"
}
''';

void main() {
  test('error parsing with details', () {
    final parsedError = json.decode(errorString);
    final cError = ConnectError.fromJson(parsedError);
    expect(cError.code, equals('unavailable'));
    expect(cError.details.length, equals(1));
  });

  test('error parsing without details', () {
    final parsedError = json.decode(errorWithoutDetails);
    final cError = ConnectError.fromJson(parsedError);
    expect(cError.code, equals('unknown'));
    expect(cError.message, equals("an unknown error has occurred"));
  });
}
