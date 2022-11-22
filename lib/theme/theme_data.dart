import "package:flutter/material.dart";

ThemeData lightTheme = ThemeData(
    fontFamily: "QuickSand",
    brightness: Brightness.light,
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xffFD5165)))),
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: Color(0xff181920)),
      labelMedium: TextStyle(color: Color(0xff181920)),
      labelLarge: TextStyle(color: Color(0xff181920)),
      titleSmall: TextStyle(color: Color(0xff181920)),
      titleMedium: TextStyle(color: Color(0xff181920)),
      titleLarge: TextStyle(color: Color(0xff181920)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Color(0xff949292))),
    iconTheme: const IconThemeData(color: Color(0xff949292)));

ThemeData darkTheme = ThemeData(
  fontFamily: "QuickSand",
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff181920),
  textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xffFD5165)))),
  inputDecorationTheme:
      const InputDecorationTheme(hintStyle: TextStyle(color: Colors.white)),
  textTheme: const TextTheme(
    labelSmall: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
  ),
);
