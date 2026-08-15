import 'package:flutter/material.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String mode = 'Ingrediente';
  bool showingResult = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escáner GASTROORIGEN')),
      body: SafeArea(
        child: Padding(
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
                children: ['Ingrediente', 'Platillo', 'No estoy seguro']
                    .map((item) => ChoiceChip(
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
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF063B2D),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD59A1C), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 86,
                        color: Color(0x99FFFFFF),
                      ),
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF1C15B), width: 2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      const Positioned(
                        bottom: 24,
                        child: Text(
                          'Coloca el ingrediente dentro del recuadro',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => setState(() => showingResult = true),
                icon: const Icon(Icons.camera),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('SIMULAR ESCANEO'),
                ),
              ),
              if (showingResult) ...[
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Posible identificación',
                          style: TextStyle(fontSize: 13, color: Color(0xFF69685F)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chile poblano',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Coincidencia de demostración: 94%'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                child: const Text('Sí, es correcto'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Ver opciones'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
