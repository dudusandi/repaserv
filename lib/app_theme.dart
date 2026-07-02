import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const backgroundColor = Color(0xFFFAF7F2);
const surfaceColor = Color(0xFFFFFFFF);
const primaryColor = Color(0xFFA8B5A0);
const primaryTextColor = Color(0xFF4A453E);
const secondaryTextColor = Color(0xFF7D766C);
const secondaryBackgroundColor = Color(0xFFF2EFE9);
const dividerColor = Color(0xFFEEE7DC);
const errorColor = Color(0xFFCC8B8B);
const appMaxWidth = 430.0;

class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

Widget buildAppViewport(BuildContext context, Widget? child) {
  return AppViewport(child: child ?? const SizedBox.shrink());
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 60,
          fontWeight: FontWeight.w800,
          height: 1.05,
          color: primaryTextColor,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: primaryTextColor,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: primaryTextColor,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: primaryTextColor,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: secondaryTextColor,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: secondaryTextColor,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: surfaceColor,
    ),
    useMaterial3: true,
  );
}
