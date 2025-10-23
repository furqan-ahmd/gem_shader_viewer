import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;

enum GemSourceType { bytes, asset, network }

class GemSource {
  const GemSource._(this.type,
      {this.bytes, this.assetPath, this.bundle, this.url, this.headers});

  final GemSourceType type;
  final Uint8List? bytes;
  final String? assetPath;
  final AssetBundle? bundle;
  final String? url;
  final Map<String, String>? headers;

  factory GemSource.memory(Uint8List data) =>
      GemSource._(GemSourceType.bytes, bytes: Uint8List.fromList(data));

  factory GemSource.asset(String path, {AssetBundle? bundle}) =>
      GemSource._(GemSourceType.asset, assetPath: path, bundle: bundle);

  factory GemSource.network(String url, {Map<String, String>? headers}) =>
      GemSource._(GemSourceType.network, url: url, headers: headers);

  Future<Uint8List> loadBytes({http.Client? client}) async {
    switch (type) {
      case GemSourceType.bytes:
        return bytes!;
      case GemSourceType.asset:
        final loader = bundle ?? rootBundle;
        final data = await loader.load(assetPath!);
        return data.buffer.asUint8List();
      case GemSourceType.network:
        final httpClient = client ?? http.Client();
        try {
          final response =
              await httpClient.get(Uri.parse(url!), headers: headers);
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return response.bodyBytes;
          }
          throw Exception('Failed to load GLB (${response.statusCode})');
        } finally {
          client ?? httpClient.close();
        }
    }
  }
}
