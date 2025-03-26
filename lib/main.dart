import 'package:flutter/material.dart';
import 'package:offline_blog_app/providers/post_provider.dart' show PostProvider;
import 'package:offline_blog_app/screens/home_screen.dart' show HomeScreen;
import 'package:offline_blog_app/services/database_service.dart' show DatabaseService;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseService.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a modern color scheme with a dark teal primary color and coral accent
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00796B), // Teal
      primary: const Color(0xFF00796B),
      secondary: const Color(0xFFFF7043), // Coral
      tertiary: const Color(0xFF26A69A), // Light teal
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        title: 'Offline Blogger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          visualDensity: VisualDensity.adaptivePlatformDensity,

          // Modern card theme with subtle elevation
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
          ),

          // Custom app bar theme
          // appBarTheme: AppBarTheme(
          //   backgroundColor: colorScheme.primary,
          //   foregroundColor: Colors.white,
          //   elevation: 0,
          //   centerTitle: false,
          //   shape: const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(
          //       bottom: Radius.circular(16),
          //     ),
          //   ),
          // ),

          // Modern floating action button theme
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Text themes for consistent typography
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Input decoration theme for text fields
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
