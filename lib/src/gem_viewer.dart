import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'gem_source.dart';
import 'html_template.dart';
import 'web/html_gem_view_stub.dart'
    if (dart.library.html) 'web/html_gem_view.dart' as web_view;

class GemViewer extends StatefulWidget {
  const GemViewer({
    super.key,
    required this.source,
    required this.seed,
    this.placeholder,
    this.errorBuilder,
  });

  factory GemViewer.memory(
    Uint8List bytes, {
    required String seed,
    Key? key,
    Widget? placeholder,
    Widget Function(Object error)? errorBuilder,
  }) =>
      GemViewer(
        key: key,
        source: GemSource.memory(bytes),
        seed: seed,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
      );

  factory GemViewer.asset(
    String path, {
    required String seed,
    Key? key,
    Widget? placeholder,
    Widget Function(Object error)? errorBuilder,
  }) =>
      GemViewer(
        key: key,
        source: GemSource.asset(path),
        seed: seed,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
      );

  factory GemViewer.network(
    String url, {
    required String seed,
    Key? key,
    Map<String, String>? headers,
    Widget? placeholder,
    Widget Function(Object error)? errorBuilder,
  }) =>
      GemViewer(
        key: key,
        source: GemSource.network(url, headers: headers),
        seed: seed,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
      );

  final GemSource source;
  final String seed;
  final Widget? placeholder;
  final Widget Function(Object error)? errorBuilder;

  @override
  State<GemViewer> createState() => _GemViewerState();
}

class _GemViewerState extends State<GemViewer> {
  WebViewController? _controller;
  bool _isReady = false;
  Object? _error;
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000));
    }
    _loadContent();
  }

  @override
  void didUpdateWidget(covariant GemViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed || oldWidget.source != widget.source) {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _isReady = false;
      _error = null;
      if (kIsWeb) {
        _htmlContent = null;
      }
    });

    try {
      final bytes = await widget.source.loadBytes();
      final base64 = base64Encode(bytes);
      final html = buildGemHtml(seed: widget.seed, glbBase64: base64);

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _htmlContent = html;
          _isReady = true;
        });
      } else {
        await _controller!.loadHtmlString(html);
        if (!mounted) return;
        setState(() {
          _isReady = true;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!);
      }
      return Center(
        child: Text(
          'Failed to load gem: $_error',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isReady) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return web_view.buildWebGemView(
        html: _htmlContent,
        placeholder: widget.placeholder ??
            const Center(child: CircularProgressIndicator()),
      );
    }

    return WebViewWidget(controller: _controller!);
  }
}
