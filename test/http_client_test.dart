import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/core.dart';
import './rpc/greet.pb.dart' as greet;

final mockClient = MockClient((request) async {
  if (request.url.path != "/greet.v1.GreetService/Greet") {
    return http.Response("", 404);
  }

  final response =
      greet.GreetResponse(greeting: 'hello, tester').writeToBuffer();

  return http.Response.bytes(response, 200, headers: {
    'content-type': 'application/proto',
    'content-length': response.length.toString()
  });
});

final mockClientWithError = MockClient((request) async {
  final response = '''
  {
     "code":"unimplemented",
     "message":"an unknown error has occurred"
  }
''';

  return http.Response(response, 404, headers: {
    'content-type': 'application/json',
    'content-length': response.length.toString()
  });
});

void main() {
  final request = greet.GreetRequest(name: 'tester');

  test('perform request', () async {
    final client = HttpConnectClient('http://localhost', mockClient);

    final response = await client.PerformRequest('/greet.v1.GreetService/Greet',
        request, (b) => greet.GreetResponse.fromBuffer(b));

    expect(response.isError, equals(false));
    expect(response.response!.greeting, equals('hello, tester'));
    expect(response.error, equals(null));
  });

  test('perform with error', () async {
    final client = HttpConnectClient('http://localhost', mockClientWithError);

    final response = await client.PerformRequest('/greet.v1.GreetService/Greet',
        request, (b) => greet.GreetResponse.fromBuffer(b));

    expect(response.isError, equals(true));
    expect(response.error!.code, equals('unimplemented'));
    expect(response.response, equals(null));
  });
}
