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
  String? _glbUrl;
  String _seed = 'gem-42';
  bool _isPicking = false;

  final TextEditingController _seedController = TextEditingController(
    text: 'gem-42',
  );
  final TextEditingController _urlController = TextEditingController(text: "https://d19mv2lmdsngzz.cloudfront.net/glb/282ba3af-ad41-46d6-8b04-39ccc31d3625");

  @override
  void dispose() {
    _seedController.dispose();
    _urlController.dispose();
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
            _glbUrl = null;
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

  void _applyUrl() {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _glbUrl = null;
      });
      return;
    }
    setState(() {
      _glbUrl = raw;
      _glbBytes = null;
      _fileName = raw;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final padding = media.padding;
    final isVertical = media.size.height > media.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF04050A),
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.only(
            left: max(12, padding.left + 12),
            right: max(12, padding.right + 12),
            top: padding.top + 12,
            bottom: padding.bottom + 12,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900 && !isVertical;
              final controls = _ControlsPanel(
                isPicking: _isPicking,
                fileName: _fileName,
                onPickGlb: _pickGlb,
                seedController: _seedController,
                onSeedChanged: _applySeed,
                onRandomize: _randomizeSeed,
                urlController: _urlController,
                onLoadUrl: _applyUrl,
                compact: !wide,
              );
              final viewer = _ViewerPanel(
                glbBytes: _glbBytes,
                glbUrl: _glbUrl,
                seed: _seed,
              );
              return Column(
                children: [
                  if (!wide) controls,
                  if (!wide) const SizedBox(height: 16),
                  Expanded(
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: min(360, constraints.maxWidth * 0.32),
                                child: controls,
                              ),
                              const SizedBox(width: 24),
                              Expanded(child: viewer),
                            ],
                          )
                        : viewer,
                  ),
                ],
              );
            },
          ),
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
    required this.urlController,
    required this.onLoadUrl,
    required this.compact,
  });

  final bool isPicking;
  final String? fileName;
  final VoidCallback onPickGlb;
  final TextEditingController seedController;
  final ValueChanged<String> onSeedChanged;
  final VoidCallback onRandomize;
  final TextEditingController urlController;
  final VoidCallback onLoadUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334866FF)),
        gradient: const LinearGradient(
          colors: [Color(0x22101635), Color(0x22080C1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
              'Load a .glb mesh locally or via URL and provide a seed to reproduce procedural skins across platforms.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            OverflowBar(
              spacing: 12,
              alignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: compact ? double.infinity : 180,
                  child: ElevatedButton.icon(
                    onPressed: isPicking ? null : onPickGlb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16204A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.file_upload_outlined),
                    label: Text(isPicking ? 'Loading…' : 'Select .glb'),
                  ),
                ),
                SizedBox(
                  width: compact ? double.infinity : 180,
                  child: ElevatedButton.icon(
                    onPressed: onLoadUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2658),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.link_outlined),
                    label: const Text('Load URL'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fileName ?? 'No source selected',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 32, color: Color(0x33FFFFFF)),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => onLoadUrl(),
              decoration: InputDecoration(
                labelText: 'Remote GLB URL',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'https://example.com/model.glb',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0x33141830),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
              'The same seed and mesh renders the exact look on web, Android, and iOS. Remote GLBs require CORS.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerPanel extends StatelessWidget {
  const _ViewerPanel({
    required this.glbBytes,
    required this.glbUrl,
    required this.seed,
  });

  final Uint8List? glbBytes;
  final String? glbUrl;
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
        child: glbUrl != null
            ? GemViewer.network(
                glbUrl!,
                seed: seed,
                placeholder: const Center(child: CircularProgressIndicator()),
                errorBuilder: (error) =>
                    _FailureView(message: error.toString()),
              )
            : glbBytes != null
            ? GemViewer.memory(
                glbBytes!,
                seed: seed,
                placeholder: const Center(child: CircularProgressIndicator()),
                errorBuilder: (error) =>
                    _FailureView(message: error.toString()),
              )
            : const _PlaceholderView(),
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
              'Select a GLB file or provide a URL to begin',
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

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Failed to render gem',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
