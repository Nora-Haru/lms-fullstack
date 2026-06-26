import 'package:client_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/module_provider.dart';

// Impor komponen yang baru saja kita pisahkan
import '../../core/theme/app_colors.dart';
import 'widgets/home_widgets.dart';
import 'widgets/app_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedProgress = 'Semua progres';
  //bool _isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();

  static const _kProgressFilters = [
    'Semua progres',
    'Belum mulai',
    'Sedang berjalan',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<ModuleProvider>().fetchModules(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Ekstraksi Identitas Dinamis ──
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final namaDepan = user?['name']?.split(' ')[0] ?? 'Siswa';
    final role = user?['role'] == 'teacher' ? 'Guru' : 'Siswa';
    final themeProvider = context.watch<ThemeProvider>();

    String namaJurusan = 'UMUM';
    if (user?['student']?['classroom']?['department']?['code'] != null) {
      namaJurusan = user!['student']['classroom']['department']['code'];
    }

    // ── Ekstraksi Data Modul ──
    final moduleProvider = context.watch<ModuleProvider>();
    final isModulesLoading = moduleProvider.isLoading;
    final modules = moduleProvider.modules;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Memanggil AppBar dari home_widgets.dart
            AppNavbar( // <-- Ganti HomeAppBar menjadi AppNavbar
              isDarkMode: themeProvider.isDarkMode,
              onToggleDarkMode: () => themeProvider.toggleTheme(),
              namaRole: role,
              namaJurusan: namaJurusan,
              namaLengkap: user?['name'] ?? 'Pengguna',
              email: user?['email'] ?? '',
              onLogout: () => auth.logout(),
              // showBackButton: false, // Di Home tidak ada tombol kembali
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeSection(nama: namaDepan),
                    const SizedBox(height: 20),
                    
                    if (modules.isNotEmpty) ...[
                      ContinueLearningCard(module: modules.first),
                    ] else if (isModulesLoading) ...[
                      Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ],
                    
                    const SizedBox(height: 28),
                    SectionHeader(
                      title: 'Mata Pelajaran',
                      subtitle: 'Cari, filter, dan pilih modul untuk mulai belajar',
                    ),
                    const SizedBox(height: 16),
                    HomeSearchBar(controller: _searchController),
                    const SizedBox(height: 12),
                    FilterChipRow(
                      items: _kProgressFilters,
                      selected: _selectedProgress,
                      activeColor: AppColors.progressFilter,
                      onTap: (val) => setState(() => _selectedProgress = val),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Grid modul ──
            if (isModulesLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (modules.isEmpty)
              const SliverToBoxAdapter(child: EmptyModuleState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SubjectCard(subject: modules[i]),
                    childCount: modules.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}