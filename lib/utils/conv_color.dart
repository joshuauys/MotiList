import 'package:flutter/material.dart';

// converts hex String to a Color object

hexStringToColor(String hex) {
  hex = hex.toUpperCase().replaceAll("#", "");
  if(hex.length == 6) {
    hex = "FF" + hex;
  }
  return Color(int.parse(hex, radix: 16));
}