import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart';

const _protobufContentType = 'application/proto';

// A container for a connect request
class ConnectRequest<T extends GeneratedMessage> {
  final T request;

  ConnectRequest(this.request) {}
}

// Sum type that contains either a [ConnectError] or a response
class ConnectResponse<T> {
  // optional response
  final T? response;
  // optional error
  final ConnectError? error;

  // constructs a response
  ConnectResponse(this.response, this.error) {}

  // returns true if the response is an error
  bool get isError => error != null;
}

// A ResponseDecoder takes in the bytes of a response, and returns a concrete
// response type
typedef ResponseDecoder<S> = S Function(List<int>);

// The abstract base class for any Connect client.
abstract class ConnectClient {
  // PerformRequest will return a [ConnectResponse] with parameterized type or an error
  Future<ConnectResponse<T>> PerformRequest<RT extends GeneratedMessage, T>(
      String path, RT request, ResponseDecoder<T> decoder);
}

// Implementation of [ConnectClient] that uses a nominal http client
class HttpConnectClient implements ConnectClient {
  final String hostname;
  final http.BaseClient httpClient;

  // Construct an HTTP based ConnectClient
  HttpConnectClient(this.hostname, this.httpClient) {}

  // Builds a request from the given path, and performs the request
  Future<ConnectResponse<T>> PerformRequest<RT extends GeneratedMessage, T>(
      String path, RT request, ResponseDecoder<T> decoder) async {
    final url = '$hostname$path';
    final uri = Uri.parse(url);
    final body = request.writeToBuffer();
    final headers = {
      'Content-Type': _protobufContentType,
      'Content-Length': body.length.toString()
    };

    final response = await httpClient.post(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      return ConnectResponse(null, _decodeError(response));
    }

    return ConnectResponse(decoder(response.bodyBytes), null);
  }

  // decodes a JSON error from connect
  ConnectError _decodeError(http.Response response) {
    try {
      final value = json.decode(response.body);
      return ConnectError.fromJson(value);
    } catch (e) {
      return ConnectError('unknown', response.body, <ConnectErrorDetail>[]);
    }
  }
}

// A wrapper class for Connect error details
class ConnectErrorDetail {
  // error detail type
  final String type;
  // error detail value
  final String value;

  // constructor for error detail
  ConnectErrorDetail(this.type, this.value) {}

  // factory to build error detail from JSON
  factory ConnectErrorDetail.fromJson(Map<String, dynamic> json) {
    return ConnectErrorDetail(json['type'] as String, json['value'] as String);
  }
}

// A wrapper class for Connect errors
class ConnectError {
  // error code
  final String code;
  // error message
  final String message;

  // error details which can be empty
  final List<ConnectErrorDetail> details;

  // constructor for the Connect error
  ConnectError(this.code, this.message, this.details) {}

// factory to build error detail from JSON
  factory ConnectError.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String;
    final message = json['message'] as String;

    if (json['details'] != null) {
      final details =
          json['details'].map((d) => ConnectErrorDetail.fromJson(d));
      return ConnectError(
          code, message, new List<ConnectErrorDetail>.from(details));
    }
    return ConnectError(code, message, <ConnectErrorDetail>[]);
  }
}
