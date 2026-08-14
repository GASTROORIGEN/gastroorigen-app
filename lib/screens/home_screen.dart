import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature se conectará en el siguiente paso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  color: const Color(0xFFF0E0C8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD7BE9B)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'GASTROORIGEN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'México se cuenta a través de sus sabores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.35),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Espacio reservado para el logo oficial',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escanea un ingrediente o platillo y descubre su origen, historia y usos gastronómicos.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => _comingSoon(context, 'El escáner'),
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
                onPressed: () => _comingSoon(context, 'Galería'),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text('SUBIR UNA FOTOGRAFÍA'),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Explora GASTROORIGEN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
