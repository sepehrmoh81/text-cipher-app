import 'package:flutter/material.dart';
import 'package:text_cipher_app/utils/hex_color_extension.dart';
import 'package:web/web.dart' as web;


void setMetaThemeColor(Color color) {
  final hexColor = color.toRgbHex();

  final metaTag = web.document.querySelector('meta[name="theme-color"]') as web.HTMLMetaElement?;
  if (metaTag != null) {
    metaTag.content = hexColor;
  }

  final body = web.document.body;
  if (body != null) {
    body.style.backgroundColor = hexColor;
  }
}