# gem_shader_viewer

Deterministic gem renderer for Flutter that mirrors the procedural shader system from the React prototype. Give it a lightweight `.glb` mesh and a seed string and it generates the exact same look on web, Android, and iOS by embedding a Three.js powered WebView.

## Installing

```yaml
dependencies:
  gem_shader_viewer:
    git:
      url: https://github.com/your-org/gem_shader_viewer.git
```

(Replace the git source with your own path if you are consuming locally.)

## Usage

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gem_shader_viewer/gem_shader_viewer.dart';

class GemPreview extends StatelessWidget {
  const GemPreview({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return GemViewer.memory(
      bytes,
      seed: 'gem-42',
      placeholder: const Center(child: CircularProgressIndicator()),
      errorBuilder: (error) => Center(child: Text('Failed: $error')),
    );
  }
}
```

The API stays intentionally close to `flutter_3d_controller`:

- `GemViewer.memory` – render an in-memory `.glb` buffer
- `GemViewer.asset` – load from bundled assets
- `GemViewer.network` – fetch a `.glb` from a URL

Supply any seed string; the material factory will derive palettes, effect weights, and animation parameters deterministically.

## Web demo / example

An interactive Flutter web demo lives in `example/`. It lets you upload a `.glb` file, type a seed, and watch the gem update in real time.

```
cd example
flutter run -d chrome
```

The demo uses `file_picker` to accept a GLB from disk and pipes the bytes straight into `GemViewer.memory`.

## Notes

- Keep meshes small (≤100 KB, low poly counts) for fast WebView startup.
- The viewer is transparent; wrap it in your own background/container as needed.
- Because the shader runs inside WebGL, performance depends mostly on fragment load. Consider lowering viewport size on older devices.
