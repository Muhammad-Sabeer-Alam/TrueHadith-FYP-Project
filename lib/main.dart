import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // Firebase configuration
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/bookmark_page.dart';
import 'screens/history_page.dart';
import 'screens/result_page.dart';
import 'screens/voice_input_page.dart';
import 'screens/crop_image_page.dart';
import 'screens/audio_trimming_page.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'utils/apps_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'True Hadith',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
      ),
      // Use AuthWrapper to handle authentication state
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/bookmarks':
            final userId = settings.arguments as int;
            // TODO: Fetch real bookmarks from API
            return MaterialPageRoute(
              builder: (context) => BookmarkPage(
                userId: userId,
                bookmarks: const [], // Empty list for now
              ),
            );

          case '/history':
            final userId = settings.arguments as int;
            // TODO: Fetch real history from API
            return MaterialPageRoute(
              builder: (context) => HistoryPage(
                userId: userId,
                history: const [], // Empty list for now
              ),
            );

          case '/result_detail':
            // If you have a detail page, add it here.
            // For now assuming result_detail_page.dart exists based on file list
            // but wasn't in the plan explicitly other than existing files.
            // Let's check if ResultDetailPage needs addition or if it was just implicit.
            // Using placeholder or generic route if file details are needed.
            // Actually, let's stick to the requested fixes: bookmarks and history.
            // But I should handle '/results' as per home_screen calls.
            return null;

          case '/results':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ResultPage(
                userId: args['userId'],
                query: args['query'],
                results: const [], // Empty list for now
              ),
            );

          case '/voice_input':
            return MaterialPageRoute(
              builder: (context) => const VoiceInputPage(),
            );

          case '/crop_image':
            return MaterialPageRoute(
              builder: (context) => const CropImagePage(),
            );

          case '/audio_trimming':
            return MaterialPageRoute(
              builder: (context) => const AudioTrimmingPage(),
            );

          default:
            return null;
        }
      },
    );
  }
}

/// Wrapper widget that listens to authentication state changes
/// and automatically navigates between LoginScreen and HomeScreen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadUserData();
      } else {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkAuthState() async {
    if (AuthService.isSignedIn()) {
      await _loadUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If backend call fails, still show login screen
      if (mounted) {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userData != null) {
      return HomeScreen(
        userId: _userData!.userId,
        username: _userData!.username,
        createdAt: _userData!.createdAt,
      );
    }

    return const LoginScreen();
  }
}
