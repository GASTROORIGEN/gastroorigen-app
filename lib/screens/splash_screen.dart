import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(milliseconds: 2800);
  static const _background = Color(0xFF0C2A18);

  static const _splashParts = <String>[
    'assets/branding/splash_hq_part01.txt',
    'assets/branding/splash_hq_part02.txt',
    'assets/branding/splash_hq_part03.txt',
    'assets/branding/splash_hq_part04.txt',
    'assets/branding/splash_hq_part05.txt',
    'assets/branding/splash_hq_part06.txt',
    'assets/branding/splash_hq_part07.txt',
    'assets/branding/splash_hq_part08.txt',
    'assets/branding/splash_hq_part09.txt',
    'assets/branding/splash_hq_part10.txt',
    'assets/branding/splash_hq_part11.txt',
    'assets/branding/splash_hq_part12.txt',
    'assets/branding/splash_hq_part13.txt',
  ];

  Timer? _timer;
  Uint8List? _imageBytes;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _loadSplash();
  }

  Future<void> _loadSplash() async {
    try {
      final buffer = StringBuffer();
      for (final path in _splashParts) {
        buffer.write(await rootBundle.loadString(path));
      }
      final clean = buffer.toString().replaceAll(RegExp(r'\s+'), '');
      final bytes = base64Decode(clean);
      if (!mounted) return;

      setState(() => _imageBytes = bytes);
      _timer = Timer(_duration, _openHome);
    } catch (_) {
      _timer = Timer(const Duration(milliseconds: 700), _openHome);
    }
  }

  void _openHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openHome,
          child: SizedBox.expand(
            child: _imageBytes == null
                ? const ColoredBox(color: _background)
                : Image.memory(
                    _imageBytes!,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(color: _background);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
