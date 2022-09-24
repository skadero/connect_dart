/// Connect support library
///
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart';

const _protobufContentType = 'application/proto';

/// A container for a connect request
class ConnectRequest<T extends GeneratedMessage> {
  // Request specific type
  final T request;

  /// Builds a connect request
  ConnectRequest(this.request) {}
}

/// Sum type that contains either a [ConnectError] or a response
class ConnectResponse<T> {
  /// Optional response
  final T? response;

  /// Optional error
  final ConnectError? error;

  /// Constructs a response
  ConnectResponse(this.response, this.error) {}

  /// Returns true if the response is an error
  bool get isError => error != null;
}

/// A ResponseDecoder takes in the bytes of a response, and returns a concrete
/// response type
typedef ResponseDecoder<S> = S Function(List<int>);

/// The abstract base class for any Connect client.
abstract class ConnectClient {
  /// performRequest will return a [ConnectResponse] with parameterized type or an error
  Future<ConnectResponse<T>> performRequest<RT extends GeneratedMessage, T>(
      String path, RT request, ResponseDecoder<T> decoder);
}

/// Implementation of [ConnectClient] that uses a nominal http client
class HttpConnectClient implements ConnectClient {
  final String hostname;
  final http.Client httpClient;

  /// Construct an HTTP based ConnectClient
  HttpConnectClient(this.hostname, this.httpClient) {}

  /// Uses encodes request with protobuf, builds and performs an http request, and uses response
  /// decoder to parse body. Will parse error if response code is not 200.
  Future<ConnectResponse<T>> performRequest<RT extends GeneratedMessage, T>(
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

  /// Decodes a JSON error from connect
  ConnectError _decodeError(http.Response response) {
    try {
      final value = json.decode(response.body);
      return ConnectError.fromJson(value);
    } catch (e) {
      return ConnectError('unknown', response.body, <ConnectErrorDetail>[]);
    }
  }
}

/// A wrapper class for Connect error details
class ConnectErrorDetail {
  /// Error detail type
  final String type;

  /// Error detail value
  final String value;

  /// Constructor for error detail
  ConnectErrorDetail(this.type, this.value) {}

  /// Factory to build error detail from JSON
  factory ConnectErrorDetail.fromJson(Map<String, dynamic> json) {
    return ConnectErrorDetail(json['type'] as String, json['value'] as String);
  }
}

/// A wrapper class for Connect errors
class ConnectError {
  /// Error code
  final String code;

  /// Error message
  final String message;

  /// Error details which can be empty
  final List<ConnectErrorDetail> details;

  /// Constructor for the Connect error
  ConnectError(this.code, this.message, this.details) {}

  /// Factory to build error detail from JSON
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
