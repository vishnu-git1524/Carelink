// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// ThemeData lightThemeData(BuildContext context) {
//   return ThemeData.light().copyWith(
//     brightness: Brightness.light,
//     primaryColor: kPrimaryColorLight,
//     scaffoldBackgroundColor: Colors.grey[50],
//     appBarTheme: appBarTheme.copyWith(
//       color: Colors.white,
//       centerTitle: true,
//       iconTheme: IconThemeData(color: kPrimaryColorLight),
//       titleTextStyle: GoogleFonts.inter(
//         color: kContentColorLightTheme,
//         fontWeight: FontWeight.normal,
//         fontSize: 19,
//       ),
//     ),
//     iconTheme: IconThemeData(color: kContentColorLightTheme),
//     textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
//         .apply(
//           bodyColor: kContentColorLightTheme,
//           displayColor: kContentColorLightTheme,
//         )
//         .copyWith(
//           subtitle1: TextStyle(color: Colors.black),
//         ),
//     listTileTheme: ListTileThemeData(
//       subtitleTextStyle: TextStyle(color: Colors.black54),
//     ),
//     colorScheme: ColorScheme.light(
//       primary: kPrimaryColorLight,
//       secondary: kSecondaryColor,
//       error: kErrorColor,
//     ),
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       backgroundColor: Colors.white,
//       selectedItemColor: kPrimaryColorLight,
//       unselectedItemColor: kContentColorLightTheme.withOpacity(0.32),
//       selectedIconTheme: IconThemeData(color: kPrimaryColorLight),
//       showUnselectedLabels: true,
//     ),
//   );
// }

// ThemeData darkThemeData(BuildContext context) {
//   return ThemeData.dark().copyWith(
//     brightness: Brightness.dark,
//     primaryColor: kPrimaryColorDark,
//     scaffoldBackgroundColor: kBackgroundDark,
//     appBarTheme: appBarTheme.copyWith(
//       color: kBackgroundDark,
//       centerTitle: true,
//       iconTheme: IconThemeData(color: kPrimaryColorDark),
//       titleTextStyle: GoogleFonts.inter(
//         color: kContentColorDarkTheme,
//       ),
//     ),
//     iconTheme: IconThemeData(color: kContentColorDarkTheme),
//     textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
//         .apply(
//           bodyColor: kContentColorDarkTheme,
//           displayColor: kContentColorDarkTheme,
//         )
//         .copyWith(
//           subtitle1: TextStyle(color: Colors.white),
//         ),
//     colorScheme: ColorScheme.dark().copyWith(
//       primary: kPrimaryColorDark,
//       secondary: kSecondaryColor,
//       error: kErrorColor,
//     ),
//     listTileTheme: ListTileThemeData(
//       subtitleTextStyle: TextStyle(color: Colors.white54),
//     ),
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       backgroundColor: kBackgroundDark,
//       selectedItemColor: Colors.white70,
//       unselectedItemColor: kContentColorDarkTheme.withOpacity(0.32),
//       selectedIconTheme: IconThemeData(color: kPrimaryColorDark),
//       showUnselectedLabels: true,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       fillColor: Colors.grey[800],
//       hintStyle: TextStyle(
//         color: Colors.grey,
//       ),
//     ),
//   );
// }

// final appBarTheme = AppBarTheme(centerTitle: true, elevation: 0);

// // Updated colors for a chat app
// const kPrimaryColorLight = Colors.black; // Blue (iOS like)
// const kPrimaryColorDark = Colors.white; // Slightly lighter blue for dark mode
// const kSecondaryColor = Colors.lightBlue; // Green for success accents
// const kContentColorLightTheme = Color(0xFF1C1C1E); // Darker grey for light theme text
// const kContentColorDarkTheme = Color(0xFFF5F5F7); // Light grey for dark theme text
// const kBackgroundDark = Color(0xFF121212); // Dark background color
// const kWarninngColor = Color(0xFFFF9500); // Orange for warnings
// const kErrorColor = Color(0xFFFF3B30); // Red for errors
// const kActiveNowColor = Color(0xFF30D158); // Green indicating online status
// const kDefaultPadding = 20.0;

// // Other imports and code for Home widget remain unchanged

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kDefaultPadding = 20.0; // Consistent padding for UI elements

// Color Palette with Clear Names and Accessibility in Mind
const kPrimaryLight = Colors.black; // Primary for light theme (dark text)
const kPrimaryDark = Colors.white; // Primary for dark theme (light text)
const kSecondary = Colors.lightBlue; // Accent color (consistent across themes)
const kContentLight =
    Color(0xFF1C1C1E); // Text color for light theme (dark gray)
const kContentDark = Colors.white; // Text color for dark theme (white)
const kBackgroundLight = Color(0xFFF5F5F7); // Background color for light theme
const kBackgroundDark = Color(0xFF121212); // Background color for dark theme
const kWarning = Color(0xFFFF9500); // Warning color (orange)
const kError = Color(0xFFFF3B30); // Error color (red)
const kActiveNow = Color(0xFF30D158); // Online status indicator (green)

// ThemeData with Consistent Structure and Accessibility Considerations
ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
      splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
    brightness: Brightness.light,
    primaryColor: kPrimaryLight,
    scaffoldBackgroundColor: kBackgroundLight,
    appBarTheme: appBarTheme.copyWith(
      color: kBackgroundLight, // AppBar background matches light theme
      centerTitle: true,
      iconTheme:
          IconThemeData(color: kPrimaryLight), // Icons match primary color
      titleTextStyle: GoogleFonts.inter(
        color: kContentLight,
        fontWeight: FontWeight.normal,
        fontSize: 19,
      ),
    ),
    iconTheme: IconThemeData(color: kPrimaryLight), // Consistent icon color
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(
          bodyColor: kContentLight,
          displayColor: kContentLight,
        )
        .copyWith(
          titleMedium:
              TextStyle(color: Colors.black), // Maintain black for subtitles
        ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle:
          TextStyle(color: Colors.black54), // Consistent subtitle color
    ),
    colorScheme: ColorScheme.light(
      primary: kPrimaryLight,
      secondary: kSecondary,
      error: kError,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kBackgroundLight, // Matches light theme background
      selectedItemColor: kPrimaryLight, // Matches primary color
      unselectedItemColor: kContentLight.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: kPrimaryLight),
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[200], // Light background for input fields
      hintStyle: TextStyle(
        color: Colors.grey[600], // Hint text with decent contrast
      ),
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
          splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
    brightness: Brightness.dark,
    primaryColor: kPrimaryDark,
    scaffoldBackgroundColor: kBackgroundDark,
    appBarTheme: appBarTheme.copyWith(
      color: kBackgroundDark, // AppBar background matches dark theme
      centerTitle: true,
      iconTheme: IconThemeData(color: kPrimaryDark),
      titleTextStyle: GoogleFonts.inter(
        color: kContentDark,
      ),
    ),
    iconTheme: IconThemeData(color: kPrimaryDark), // Consistent icon color
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(
          bodyColor: kContentDark,
          displayColor: kContentDark,
        )
        .copyWith(
          titleMedium:
              TextStyle(color: Colors.white), // Maintain white for subtitles
        ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle:
          TextStyle(color: Colors.white54), // Consistent subtitle color
    ),
    colorScheme: ColorScheme.dark().copyWith(
      primary: kPrimaryDark,
      secondary: kSecondary,
      error: kError,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kBackgroundDark, // Matches dark theme background
      selectedItemColor: Colors.white70, // Lighter primary for selection
      unselectedItemColor: kContentDark.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: kPrimaryDark),
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[800], // Adjust for better contrast in dark mode
      hintStyle: TextStyle(
        color: Colors.grey[400], // Hint text with decent contrast
      ),
    ),
  );
}

const appBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 1,
    shadowColor: Color.fromARGB(255, 234, 248, 255));

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// // Custom colors
// const colors = [
//   Color(0xffff6767),
//   Color(0xff66e0da),
//   Color(0xfff5a2d9),
//   Color(0xfff0c722),
//   Color(0xff6a85e5),
//   Color(0xfffd9a6f),
//   Color(0xff92db6e),
//   Color(0xff73b8e5),
//   Color(0xfffd7590),
//   Color(0xffc78ae5),
// ];

// const dark = Color(0xff1f1c38);
// const error = Color(0xffff6767);
// const neutral0 = Color(0xff1d1c21);
// const neutral1 = Color(0xff615e6e);
// const kPrimaryLight = Colors.black;
// const neutral2 = Color(0xff9e9cab);
// const neutral7 = Color(0xffffffff);
// const neutral7WithOpacity = Color(0x80ffffff);
// const primary = Color(0xff6f61e8);
// const secondary = Color(0xfff5f5f7);
// const kPrimaryDark = Colors.white;
// const secondaryDark = Color(0xff2b2250);
// const kBackgroundLight = Color(0xFFF5F5F7);
// const kContentLight = Color(0xFF1C1C1E);
// const kBackgroundDark = Color(0xFF121212);
// const kContentDark = Colors.white;

// ThemeData buildLightChatTheme() {
//   return ThemeData(
//    appBarTheme: appBarTheme.copyWith(
//       color: kBackgroundLight, // AppBar background matches light theme
//       centerTitle: true,
//       iconTheme:
//           IconThemeData(color: kPrimaryLight), // Icons match primary color
//       titleTextStyle: GoogleFonts.inter(
//         color: kContentLight,
//         fontWeight: FontWeight.normal,
//         fontSize: 19,
//       ),
//     ),
//     brightness: Brightness.light,
//     primaryColor: primary,
//     backgroundColor: neutral7,
//     errorColor: error,
//     scaffoldBackgroundColor: neutral7,
//     inputDecorationTheme: InputDecorationTheme(
//       border: InputBorder.none,
//       contentPadding: EdgeInsets.zero,
//       isCollapsed: true,
//       hintStyle: TextStyle(
//         color: neutral2,
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         height: 1.5,
//       ),
//     ),
//     textTheme: TextTheme(
//       bodyText1: TextStyle(
//         color: neutral0,
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         height: 1.5,
//       ),
//       bodyText2: TextStyle(
//         color: neutral2,
//         fontSize: 12,
//         fontWeight: FontWeight.w500,
//         height: 1.333,
//       ),
//       subtitle1: TextStyle(
//         color: neutral0,
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         height: 1.428,
//       ),
//       subtitle2: TextStyle(
//         color: neutral0,
//         fontSize: 16,
//         fontWeight: FontWeight.w800,
//         height: 1.375,
//       ),
//       headline6: TextStyle(
//         color: neutral7,
//         fontSize: 12,
//         fontWeight: FontWeight.w800,
//         height: 1.333,
//       ),
//     ),
//     iconTheme: IconThemeData(
//       color: primary,
//       size: 16,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(primary),
//       ),
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: ButtonStyle(
//         foregroundColor: MaterialStateProperty.all(primary),
//       ),
//     ),
//   );
// }

// ThemeData buildDarkChatTheme() {
//   return ThemeData(
//    appBarTheme: appBarTheme.copyWith(
//       color: kBackgroundDark, // AppBar background matches dark theme
//       centerTitle: true,
//       iconTheme: IconThemeData(color: kPrimaryDark),
//       titleTextStyle: GoogleFonts.inter(
//         color: kContentDark,
//       ),
//     ),
//     brightness: Brightness.dark,
//     primaryColor: primary,
//     backgroundColor: dark,
//     errorColor: error,
//     scaffoldBackgroundColor: dark,
//     inputDecorationTheme: InputDecorationTheme(
//       border: InputBorder.none,
//       contentPadding: EdgeInsets.zero,
//       isCollapsed: true,
//       hintStyle: TextStyle(
//         color: neutral2,
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         height: 1.5,
//       ),
//     ),
//     textTheme: TextTheme(
//       bodyText1: TextStyle(
//         color: neutral7,
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         height: 1.5,
//       ),
//       bodyText2: TextStyle(
//         color: neutral7WithOpacity,
//         fontSize: 12,
//         fontWeight: FontWeight.w500,
//         height: 1.333,
//       ),
//       subtitle1: TextStyle(
//         color: neutral7,
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         height: 1.428,
//       ),
//       subtitle2: TextStyle(
//         color: neutral7,
//         fontSize: 16,
//         fontWeight: FontWeight.w800,
//         height: 1.375,
//       ),
//       headline6: TextStyle(
//         color: neutral7,
//         fontSize: 12,
//         fontWeight: FontWeight.w800,
//         height: 1.333,
//       ),
//     ),
//     iconTheme: IconThemeData(
//       color: primary,
//       size: 16,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(primary),
//       ),
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: ButtonStyle(
//         foregroundColor: MaterialStateProperty.all(primary),
//       ),
//     ),
//   );
// }

// const appBarTheme = AppBarTheme(
//     centerTitle: true,
//     elevation: 1,
//     shadowColor: Color.fromARGB(255, 234, 248, 255));
