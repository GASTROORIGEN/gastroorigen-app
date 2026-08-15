import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ScannerEntry { camera, gallery }

class ScannerScreen extends StatefulWidget {
  final ScannerEntry? entry;

  const ScannerScreen({super.key, this.entry});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  String mode = 'Ingrediente';
  Uint8List? _imageBytes;
  String? _imageName;
  int? _imageSize;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pick(
          widget.entry == ScannerEntry.camera
              ? ImageSource.camera
              : ImageSource.gallery,
        );
      });
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2048,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _imageSize = bytes.length;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la cámara o la galería. Revisa los permisos del dispositivo.',
          ),
        ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _imageSize = null;
    });
  }

  String get _sizeLabel {
    final size = _imageSize;
    if (size == null) return '';
    final mb = size / 1024 / 1024;
    return '${mb.toStringAsFixed(mb >= 1 ? 1 : 2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escáner GASTROORIGEN')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Qué quieres identificar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: ['Ingrediente', 'Platillo', 'No estoy seguro']
                    .map(
                      (item) => ChoiceChip(
                        label: Text(item),
                        selected: mode == item,
                        selectedColor: const Color(0xFFF4E3B6),
                        side: BorderSide(
                          color: mode == item
                              ? colors.tertiary
                              : const Color(0xFFD9B86A),
                        ),
                        labelStyle: TextStyle(
                          color: mode == item
                              ? colors.primary
                              : const Color(0xFF69685F),
                          fontWeight: mode == item
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => mode = item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              Container(
                height: 360,
                decoration: BoxDecoration(
                  color: const Color(0xFF063B2D),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFD59A1C),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageBytes == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 82,
                            color: Color(0x99FFFFFF),
                          ),
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFF1C15B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          const Positioned(
                            left: 22,
                            right: 22,
                            bottom: 24,
                            child: Text(
                              'Toma una foto clara o elige una imagen de tu galería.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xD900452F),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '$mode · fotografía lista para analizar',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('TOMAR FOTO'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('GALERÍA'),
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9EFCF),
                    border: Border.all(color: const Color(0xFFE6C96F)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Fotografía seleccionada\n${_imageName ?? 'imagen'} · $_sizeLabel',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD59A1C),
                    foregroundColor: const Color(0xFF2C2415),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Imagen lista. En el Paso 3B conectaremos este botón con OpenAI.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('ANALIZAR CON GASTROORIGEN'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearImage,
                  child: const Text('Cambiar fotografía'),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'En este Paso 3A la fotografía permanece en el dispositivo. Todavía no se envía a OpenAI ni a ningún servicio externo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF69685F),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
