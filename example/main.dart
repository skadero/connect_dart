import 'package:http/http.dart' as http;
import 'package:ska_connect/ska_connect.dart';
import '../test/rpc/greet.pb.dart' as greet;

Future main(List<String> args) async {
  // client can be used for multiple calls
  final client = HttpConnectClient('http://localhost', http.Client());

  // response will contain a response or an error
  final resp = await client.performRequest(
      '/greet.v1.GreetService/Greet',
      greet.GreetRequest(name: 'Chuck'),
      // decode function to generate the response type from a buffer
      (b) => greet.GreetResponse.fromBuffer(b));

  if (resp.isError) {
    // The response was an error, response.error will not be null
    print(resp.error);
  } else {
    // The call was successful
    print(resp.response!.greeting);
  }
}
