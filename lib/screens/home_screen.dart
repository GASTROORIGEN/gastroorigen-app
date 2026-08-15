import 'package:flutter/material.dart';

import '../widgets/feature_card.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature se conectará después del escáner.')),
    );
  }

  void _openScanner(BuildContext context, ScannerEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScannerScreen(entry: entry)),
    );
  }

  Widget _institutionalValue({
    required String letter,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        border: Border.all(color: const Color(0xFFEAD7A3)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4E3B6),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Color(0xFF00452F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFA62C18),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF55584F),
              fontSize: 13,
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD9B86A),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1200452F),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'GASTROORIGEN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'México se cuenta a través de sus sabores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text(
                '¿Qué quieres descubrir hoy?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escanea un ingrediente o platillo y descubre su origen, historia y usos gastronómicos.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: const Color(0xFF69685F),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => _openScanner(context, ScannerEntry.camera),
                icon: const Icon(Icons.center_focus_strong_rounded, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'ESCANEAR INGREDIENTE O PLATILLO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => _openScanner(context, ScannerEntry.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text('SUBIR UNA FOTOGRAFÍA'),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFAF0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  border: Border.all(color: const Color(0xFFE2C77E)),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F00452F),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MÉXICO SE CUENTA A TRAVÉS DE SUS SABORES',
                      style: TextStyle(
                        color: Color(0xFFD59A1C),
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      '¿Qué es GASTROORIGEN?',
                      style: TextStyle(
                        color: Color(0xFF00452F),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Una plataforma que descubre y comparte la riqueza gastronómica de México a través de sus ingredientes, platillos, historias y tradiciones.',
                      style: TextStyle(
                        color: Color(0xFF69685F),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _institutionalValue(
                      letter: 'M',
                      title: 'Misión',
                      text:
                          'Preservar y difundir la gastronomía mexicana mediante conocimiento, cultura y tecnología.',
                    ),
                    const SizedBox(height: 10),
                    _institutionalValue(
                      letter: 'V',
                      title: 'Visión',
                      text:
                          'Convertir a GASTROORIGEN en un referente digital de la gastronomía de México, conectando sus sabores con el mundo.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Explora GASTROORIGEN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
              const SizedBox(height: 14),
              FeatureCard(
                icon: Icons.search_rounded,
                title: 'Explorar',
                subtitle: 'Busca ingredientes, platillos y sabores de México.',
                onTap: () => _comingSoon(context, 'Explorar'),
              ),
              const SizedBox(height: 12),
              FeatureCard(
                icon: Icons.menu_book_rounded,
                title: 'Historias',
                subtitle: 'Conoce el origen cultural detrás de cada sabor.',
                onTap: () => _comingSoon(context, 'Historias'),
              ),
              const SizedBox(height: 12),
              FeatureCard(
                icon: Icons.person_outline_rounded,
                title: 'Mi GASTROORIGEN',
                subtitle: 'Tus descubrimientos, favoritos e historial.',
                onTap: () => _comingSoon(context, 'Mi GASTROORIGEN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
