import 'dart:convert';

import 'web/embedded_bundle.dart';

String buildGemHtml({
  required String seed,
  required String glbBase64,
}) {
  final encodedSeed = jsonEncode(seed);
  final encodedGlb = jsonEncode(glbBase64);
  final bundle = getEmbeddedBundleJs();
  final escapedBundle = bundle.replaceAll('</script>', '<\/script>');
  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background: transparent;
      overflow: hidden;
      width: 100%;
      height: 100%;
    }
    #gemCanvas {
      width: 100%;
      height: 100%;
      display: block;
    }
  </style>
</head>
<body>
  <canvas id="gemCanvas"></canvas>
  <script>$escapedBundle</script>
  <script>
    (function () {
      const seed = $encodedSeed;
      const glbBase64 = $encodedGlb;
      const canvas = document.getElementById('gemCanvas');
      if (!window.GemViewerBundle) {
        console.error('GemViewerBundle not available');
        return;
      }
      window.GemViewerBundle.initGemViewer({ canvas, glbBase64, seed }).catch((error) => {
        console.error('Gem viewer failed', error);
      });
    })();
  </script>
</body>
</html>
''';
}
