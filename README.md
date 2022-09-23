# ska_connect

Dart support package for the [Connect](https://connect.build) protocol. This is not intended for direct use, but for use with generated code. It currently supports unary requests and the http client can be customized by implementing a common interface.

This package is published as `ska_connect`, because `connect` is too generic.

## Using

This client depends on generated Dart protobuf code for the request and response types. You can get the latest precompiled binary for your system [here](https://github.com/google/protobuf/releases) and the Dart compiler [here](https://pub.dev/packages/protoc_plugin). The example proto file can be compiled with:

    protoc --proto_path=./test/proto --dart_out=./test/rpc ./test/proto/greet.proto

### Dependencies

In your `pubspec.yaml` specify:

    http: ^0.13.0
    protobuf: ^2.0.0

### Making Unary Requests

Required packages:

```dart
import 'package:http/http.dart' as http;
import 'package:ska_connect/core.dart';
import './rpc/greet.pb.dart' as greet;
```

```dart
// client can be used for multiple calls
final client = HttpConnectClient('http://localhost', http.Client());

// response will contain a response or an error
final resp = await client.PerformRequest('/greet.v1.GreetService/Greet', request,
  // decode function to generate the response type from a buffer
  (b) => greet.GreetResponse.fromBuffer(b));

if (resp.isError) {
  // The response was an error, response.error will not be null
  print(resp.error);
} else {
  // The call was successful
  print(resp.response!.greeting);
}
```


## Running tests

```
dart pub get
dart test
```
