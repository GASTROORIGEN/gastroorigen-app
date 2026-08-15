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
  String _lastSource = 'camera';
  Uint8List? _imageBytes;
  String? _imageName;
  bool _analyzing = false;
  String? _error;
  Map<String, dynamic>? _result;
  List<Map<String, dynamic>> _sources = const [];

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
      _lastSource = source == ImageSource.camera ? 'camera' : 'gallery';
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _result = null;
        _sources = const [];
        _error = null;
      });
      await _analyze();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'No se pudo abrir la cámara o la galería. Revisa los permisos del dispositivo.');
    }
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null || _analyzing) return;

    setState(() {
      _analyzing = true;
      _error = null;
      _result = null;
      _sources = const [];
    });

    try {
      final image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final response = await http
          .post(
            Uri.parse(_api),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': image,
              'mode': mode,
              'source': _lastSource,
            }),
          )
          .timeout(const Duration(seconds: 65));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          data['detail'] ?? data['error'] ?? 'Gemini no pudo analizar la fotografía.',
        );
      }

      if (!mounted) return;
      final rawSources = data['sources'];
      setState(() {
        _result = Map<String, dynamic>.from(data['result'] as Map);
        _sources = rawSources is List
            ? rawSources
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : const [];
      });
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
      _sources = const [];
      _error = null;
    });
  }

  List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  Widget _textSection(String title, dynamic value) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: Color(0xFF00452F),
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }

  Widget _listSection(String title, dynamic value) {
    final items = _strings(value);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: Color(0xFF00452F),
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 5),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: const TextStyle(height: 1.35)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, dynamic value, {String fallback = 'Por validar'}) {
    final text = (value ?? '').toString().trim();
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        border: Border.all(color: const Color(0xFFEAD9AA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFA62C18),
                fontSize: 10,
                letterSpacing: .4,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 3),
          Text(text.isEmpty ? fallback : text),
        ],
      ),
    );
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
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF6EF),
                    border: Border.all(color: const Color(0xFF9BC0A7)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '✨ Gemini 2.5 Flash + Google',
                    style: TextStyle(
                      color: Color(0xFF00452F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                children: ['Ingrediente', 'Platillo', 'No estoy seguro'].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: mode == item,
                    selectedColor: const Color(0xFFF4E3B6),
                    onSelected: (_) async {
                      setState(() => mode = item);
                      if (_imageBytes != null) await _analyze();
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
                    ? const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 88,
                          color: Color(0x99FFFFFF),
                        ),
                      )
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
                                    ? 'Gemini está analizando…'
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
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _analyzing ? null : () => _pick(ImageSource.camera),
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
                      onPressed: _analyzing ? null : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('GALERÍA'),
                      ),
                    ),
                  ),
                ],
              ),
              if (_analyzing) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text(
                  'Gemini + Google están identificando la fotografía y construyendo la ficha…',
                  textAlign: TextAlign.center,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2ED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFF7D2416)),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD59A1C),
                    foregroundColor: const Color(0xFF2C2415),
                  ),
                  onPressed: _analyzing ? null : _analyze,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('REINTENTAR CON GEMINI'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confianza visual ${r['confidence'] ?? 0}%',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${r['name'] ?? 'Identificación incierta'}',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 27,
                        ),
                      ),
                      if ((r['scientific_name'] ?? '').toString().isNotEmpty)
                        Text(
                          '${r['scientific_name']}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth > 340;
                          final fields = [
                            _field('Tipo', r['type']),
                            _field('Origen', r['origin']),
                            _field('Región en México', r['mexico_region']),
                            _field('Scoville', r['scoville'], fallback: 'No aplica'),
                          ];
                          if (!twoColumns) {
                            return Column(
                              children: fields
                                  .map((w) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: w,
                                      ))
                                  .toList(),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: fields
                                .map((w) => SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: w,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      _textSection('Descripción', r['description']),
                      _listSection('Características', r['characteristics']),
                      _listSection('Perfil de sabor', r['flavor_profile']),
                      _listSection('Usos gastronómicos', r['uses']),
                      _listSection('Platillos donde se utiliza', r['dishes']),
                      _listSection('Ingredientes principales', r['main_ingredients']),
                      _textSection('Preparación', r['preparation']),
                      _listSection('Acompañamientos', r['accompaniments']),
                      _listSection('Salsas', r['sauces']),
                      _listSection('Variantes', r['variants']),
                      _textSection('Temporalidad', r['seasonality']),
                      _textSection('Historia', r['history']),
                      _textSection('Nota cultural', r['cultural_note']),
                      if (r['needs_better_photo'] == true)
                        _textSection(
                          'Cómo mejorar la fotografía',
                          r['capture_guidance'] ?? 'Toma otra foto más clara y cercana.',
                        ),
                      if (_sources.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text(
                          'Fuentes encontradas con Google',
                          style: TextStyle(
                            color: Color(0xFF00452F),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ..._sources.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '• ${s['title'] ?? s['url'] ?? 'Fuente'}',
                              style: const TextStyle(fontSize: 12, height: 1.35),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (_imageBytes != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _analyzing ? null : _clearImage,
                  child: Text(
                    'Cambiar fotografía${_imageName == null ? '' : ' · $_imageName'}',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'La fotografía se envía al backend seguro de GASTROORIGEN y de ahí a Gemini. En el nivel gratuito de Gemini, Google indica que el contenido puede usarse para mejorar sus productos.',
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
