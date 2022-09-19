///
//  Generated code. Do not modify.
//  source: greet.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dart:core' as $core;
import 'greet.pb.dart' as $0;
import 'greet.pbjson.dart';

export 'greet.pb.dart';

abstract class GreetServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GreetResponse> greet($pb.ServerContext ctx, $0.GreetRequest request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'Greet': return $0.GreetRequest();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'Greet': return this.greet(ctx, request as $0.GreetRequest);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => GreetServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => GreetServiceBase$messageJson;
}

