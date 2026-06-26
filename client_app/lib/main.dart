// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/module_provider.dart';
import 'providers/theme_provider.dart'; // Impor ekstrinsik baru
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart'; // 1. Impor ModuleProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthSession()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // 👈 Tambahkan ini
      ],
      // Gunakan Consumer untuk memantau perubahan tema
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LMS Application',
            debugShowCheckedModeBanner: false,
            // 👈 Ini akan mengatur tema dasar (status bar, dll)
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
            darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
          );
        }
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}


// void main() {
//   runApp(const LMSApp());
// }

// class LMSApp extends StatelessWidget {
//   const LMSApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Aktifkan baris ini
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//       ],
//       child: MaterialApp(
//         title: 'LMS Platform',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//         ),
//         initialRoute: '/',
//         routes: {
//           '/': (context) => const HomeScreen(),
//         },
//       ),
//     );
//   }
// }

// void main() async {
//   // Pastikan binding Flutter terinisialisasi sebelum SharedPreferences dipanggil
//   WidgetsFlutterBinding.ensureInitialized();
  
//   runApp(const LMSApp());
// }

// class LMSApp extends StatelessWidget {
//   const LMSApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthSession()),
//       ],
//       child: MaterialApp(
//         title: 'LMS Application',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
//           useMaterial3: true,
//         ),
//         home: const AuthWrapper(), // Penentu awal apakah ke Login atau Home
//       ),
//     );
//   }
// }

// // Widget untuk mengecek: Jika punya token masuk Home, jika tidak masuk Login
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, auth, child) {
        
//         // 1. Tampilkan loading penuh HANYA saat aplikasi baru dibuka (mengecek sesi)
//         if (auth.isInitializing) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator(color: Colors.teal)),
//           );
//         }

//         // 2. Jika punya token valid, masuk ke Home
//         if (auth.isAuthenticated) {
//           return const HomeScreen();
//         } else {
//           // 3. Jika tidak ada token (atau setelah dilogout), arahkan ke LoginScreen
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }


// lib/main.dart (Pembaruan Segmen MultiProvider & MaterialApp)