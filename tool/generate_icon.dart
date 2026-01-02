import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// This script generates app icon with mosque icon
// Run: dart run tool/generate_icon.dart

void main() async {
  print('Generating app icon with mosque...');
  
  // Create SVG content for mosque icon
  final svgContent = '''
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <rect width="1024" height="1024" fill="#1A1A1A"/>
  <g transform="translate(112, 112) scale(0.78)">
    <!-- Mosque Icon in Golden Color -->
    <path fill="#D4AF37" d="M512 64c-88 0-160 72-160 160v32H192v-32c0-88-72-160-160-160H0v64h32c53 0 96 43 96 96v32H64v64h64v448h-64v64h896v-64h-64V320h64v-64h-64v-32c0-53 43-96 96-96h32V64h-32c-88 0-160 72-160 160v32H352v-32c0-88-72-160-160-160h-32V64h352zm160 256v448h-64V320h64zm-192 0v448h-64V320h64zm-192 0v448H224V320h64zm448 0v448h-64V320h64zm192 0v448h-64V320h64z"/>
    <!-- Main Dome -->
    <ellipse cx="512" cy="160" rx="200" ry="120" fill="#D4AF37"/>
    <!-- Minaret 1 -->
    <rect x="80" y="200" width="80" height="568" fill="#D4AF37"/>
    <polygon points="120,100 160,200 80,200" fill="#D4AF37"/>
    <!-- Minaret 2 -->
    <rect x="864" y="200" width="80" height="568" fill="#D4AF37"/>
    <polygon points="904,100 944,200 864,200" fill="#D4AF37"/>
    <!-- Door -->
    <rect x="432" y="568" width="160" height="200" rx="80" fill="#1A1A1A"/>
    <!-- Windows -->
    <circle cx="320" cy="480" r="40" fill="#1A1A1A"/>
    <circle cx="704" cy="480" r="40" fill="#1A1A1A"/>
    <!-- Crescent on dome -->
    <path d="M512 60 C 540 60, 560 80, 560 100 C 540 90, 520 90, 512 100 C 504 90, 484 90, 464 100 C 464 80, 484 60, 512 60" fill="#D4AF37"/>
  </g>
</svg>
''';

  print('SVG content created');
  print('Please use an online SVG to PNG converter or design tool to create:');
  print('1. assets/icons/app_icon.png (1024x1024)');
  print('2. assets/icons/app_icon_foreground.png (1024x1024 with transparent background)');
  print('');
  print('Then run: flutter pub run flutter_launcher_icons');
}
