// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

Widget buildWebGemView({required String? html, Widget? placeholder}) {
  return _HtmlGemView(html: html, placeholder: placeholder);
}

class _HtmlGemView extends StatefulWidget {
  const _HtmlGemView({required this.html, this.placeholder});

  final String? html;
  final Widget? placeholder;

  @override
  State<_HtmlGemView> createState() => _HtmlGemViewState();
}

class _HtmlGemViewState extends State<_HtmlGemView> {
  String? _viewType;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant _HtmlGemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.html != oldWidget.html) {
      _registerView();
    }
  }

  void _registerView() {
    final htmlContent = widget.html;
    if (htmlContent == null) {
      setState(() {
        _viewType = null;
      });
      return;
    }
    final viewType =
        'gem-view-${DateTime.now().microsecondsSinceEpoch}-${hashCode}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..setAttribute(
            'allow', 'accelerometer; gyroscope; magnetometer; autoplay')
        ..setAttribute('scrolling', 'no')
        ..srcdoc = htmlContent;
      return iframe;
    });
    setState(() {
      _viewType = viewType;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_viewType == null) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return HtmlElementView(viewType: _viewType!);
  }
}
