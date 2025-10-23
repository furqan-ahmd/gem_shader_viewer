import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gem_shader_viewer/gem_shader_viewer.dart';

void main() {
  runApp(const GemDemoApp());
}

class GemDemoApp extends StatelessWidget {
  const GemDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gem Shader Viewer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4450F7)),
        useMaterial3: true,
      ),
      home: const GemDemoPage(),
    );
  }
}

class GemDemoPage extends StatefulWidget {
  const GemDemoPage({super.key});

  @override
  State<GemDemoPage> createState() => _GemDemoPageState();
}

class _GemDemoPageState extends State<GemDemoPage> {
  Uint8List? _glbBytes;
  String? _fileName;
  String _seed = 'gem-42';
  bool _isPicking = false;
  final TextEditingController _seedController = TextEditingController(
    text: 'gem-42',
  );

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _pickGlb() async {
    setState(() {
      _isPicking = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: const ['glb'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final bytes = file.bytes;
        if (bytes != null) {
          setState(() {
            _glbBytes = Uint8List.fromList(bytes);
            _fileName = file.name;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _randomizeSeed() {
    final random = Random();
    final nextSeed = List.generate(8, (_) => random.nextInt(36))
        .map(
          (i) => i < 10
              ? String.fromCharCode(48 + i)
              : String.fromCharCode(87 + i),
        )
        .join();
    setState(() {
      _seed = nextSeed;
      _seedController.text = nextSeed;
    });
  }

  void _applySeed(String value) {
    setState(() {
      _seed = value.trim().isEmpty ? 'gem-42' : value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04050A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            final controls = _ControlsPanel(
              isPicking: _isPicking,
              fileName: _fileName,
              onPickGlb: _pickGlb,
              seedController: _seedController,
              onSeedChanged: _applySeed,
              onRandomize: _randomizeSeed,
            );
            final viewer = _ViewerPanel(glbBytes: _glbBytes, seed: _seed);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 340, child: controls),
                        const SizedBox(width: 24),
                        Expanded(child: viewer),
                      ],
                    )
                  : Column(
                      children: [
                        controls,
                        const SizedBox(height: 24),
                        Expanded(child: viewer),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.isPicking,
    required this.fileName,
    required this.onPickGlb,
    required this.seedController,
    required this.onSeedChanged,
    required this.onRandomize,
  });

  final bool isPicking;
  final String? fileName;
  final VoidCallback onPickGlb;
  final TextEditingController seedController;
  final ValueChanged<String> onSeedChanged;
  final VoidCallback onRandomize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334866FF)),
        gradient: const LinearGradient(
          colors: [Color(0x22101635), Color(0x22080C1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Gem Shader Demo',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Load a .glb mesh and provide a seed to reproduce procedural skins across platforms.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isPicking ? null : onPickGlb,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16204A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(isPicking ? 'Loading…' : 'Select .glb file'),
          ),
          const SizedBox(height: 12),
          Text(
            fileName ?? 'No file selected',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const Divider(height: 32, color: Color(0x33FFFFFF)),
          TextField(
            controller: seedController,
            style: const TextStyle(color: Colors.white),
            onChanged: onSeedChanged,
            decoration: InputDecoration(
              labelText: 'Seed',
              labelStyle: const TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                onPressed: onRandomize,
                icon: const Icon(Icons.casino_outlined),
                color: Colors.white70,
              ),
              filled: true,
              fillColor: const Color(0x33141830),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x335B6EFF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5B6EFF)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The same seed and mesh will render the exact look on web, Android, and iOS.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ViewerPanel extends StatelessWidget {
  const _ViewerPanel({required this.glbBytes, required this.seed});

  final Uint8List? glbBytes;
  final String seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x334866FF)),
        color: const Color(0x11080A1A),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: glbBytes == null
            ? const _PlaceholderView()
            : GemViewer.memory(
                glbBytes!,
                seed: seed,
                placeholder: const Center(child: CircularProgressIndicator()),
                errorBuilder: (error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to render gem\n$error',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.grid_on_outlined, color: Colors.white24, size: 72),
            SizedBox(height: 16),
            Text(
              'Select a GLB file to begin',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Seeds drive deterministic shader blends across every platform.',
              style: TextStyle(color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
