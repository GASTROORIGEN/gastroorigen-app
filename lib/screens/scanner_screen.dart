import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

enum ScannerEntry { camera, gallery }

class ScannerScreen extends StatefulWidget {
  final ScannerEntry? entry;
  const ScannerScreen({super.key, this.entry});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  static const _api = 'https://gastroorigen-api.vercel.app/api/analyze';
  final ImagePicker _picker = ImagePicker();

  String mode = 'Ingrediente';
  Uint8List? _imageBytes;
  String? _imageName;
  bool _analyzing = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pick(widget.entry == ScannerEntry.camera
            ? ImageSource.camera
            : ImageSource.gallery);
      });
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1280,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _result = null;
        _error = null;
      });
      await _analyze(source == ImageSource.camera ? 'camera' : 'gallery');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'No se pudo abrir la cámara o la galería. Revisa los permisos del dispositivo.');
    }
  }

  Future<void> _analyze([String source = 'camera']) async {
    final bytes = _imageBytes;
    if (bytes == null || _analyzing) return;
    setState(() {
      _analyzing = true;
      _error = null;
      _result = null;
    });
    try {
      final image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final response = await http.post(
        Uri.parse(_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': image, 'mode': mode, 'source': source}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['detail'] ?? data['error'] ?? 'No se pudo analizar.');
      }
      if (!mounted) return;
      setState(() => _result = Map<String, dynamic>.from(data['result'] as Map));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final r = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Cámara inteligente GASTROORIGEN')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Qué quieres identificar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colors.primary)),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: ['Ingrediente', 'Platillo', 'No estoy seguro'].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: mode == item,
                    selectedColor: const Color(0xFFF4E3B6),
                    onSelected: (_) async {
                      setState(() => mode = item);
                      if (_imageBytes != null) await _analyze('camera');
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                height: 360,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF063B2D),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFD59A1C), width: 1.5),
                ),
                child: _imageBytes == null
                    ? const Center(child: Icon(Icons.camera_alt_outlined, size: 88, color: Color(0x99FFFFFF)))
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_imageBytes!, fit: BoxFit.contain),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xD900452F),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _analyzing
                                    ? 'Analizando automáticamente con IA…'
                                    : r != null
                                        ? '${r['name'] ?? 'Resultado'} · ${r['confidence'] ?? 0}%'
                                        : 'Fotografía lista',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: FilledButton.icon(
                  onPressed: _analyzing ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('TOMAR FOTO')),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _analyzing ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('GALERÍA')),
                )),
              ]),
              if (_analyzing) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text('IA de cámara activa: identificando la fotografía…', textAlign: TextAlign.center),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: const Color(0xFFFFF2ED), borderRadius: BorderRadius.circular(14)),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFF7D2416))),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD59A1C), foregroundColor: const Color(0xFF2C2415)),
                  onPressed: _analyzing ? null : () => _analyze('camera'),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('REINTENTAR ANÁLISIS'),
                ),
              ],
              if (r != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF8),
                    border: Border.all(color: const Color(0xFFE5CF98)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Confianza ${r['confidence'] ?? 0}%', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${r['name'] ?? 'Identificación incierta'}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w900, fontSize: 27)),
                    if ((r['scientific_name'] ?? '').toString().isNotEmpty)
                      Text('${r['scientific_name']}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 10),
                    Text('Tipo: ${r['type'] ?? 'Por determinar'}'),
                    if (r['needs_better_photo'] == true) ...[
                      const SizedBox(height: 10),
                      Text('Mejora la foto: ${r['capture_guidance'] ?? ''}', style: const TextStyle(color: Color(0xFFA62C18), fontWeight: FontWeight.w700)),
                    ],
                  ]),
                ),
              ],
              if (_imageBytes != null) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: _analyzing ? null : _clearImage, child: Text('Cambiar fotografía${_imageName == null ? '' : ' · $_imageName'}')),
              ],
              const SizedBox(height: 10),
              const Text(
                'La IA se activa automáticamente después de tomar la foto. La visión identifica el objeto; la historia, origen y contexto cultural se completan desde la base editorial de GASTROORIGEN.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF69685F), fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
