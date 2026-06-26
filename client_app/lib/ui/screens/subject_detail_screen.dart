// lib/ui/screens/subject_detail_screen.dart

import 'package:client_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/module_item.dart';
import '../../providers/auth_provider.dart';
import 'widgets/app_navbar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SubjectDetailScreen extends StatefulWidget {
  final ModuleItem subject;
  final int initialModuleIndex; // 👈 1. Tambahkan parameter penerima index

  const SubjectDetailScreen({
    super.key, 
    required this.subject,
    this.initialModuleIndex = 0, // 👈 2. Beri nilai default 0 (Modul 1) agar aman
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool _isBookmarked = false;
  
  // State manajemen indeks modul aktif & kontrol ekspansi akordion pertemuan
  late int _currentModuleIndex; // 👈 3. Ubah menjadi 'late'
  int? _expandedMeetingIndex;

  // 👈 4. Tambahkan fungsi initState untuk menangkap index dari luar
  @override
  void initState() {
    super.initState();
    _currentModuleIndex = widget.initialModuleIndex; 
  }

  // Menghitung data sesi pertemuan secara dinamis dari database modul aktif
  List<dynamic> get _currentMeetings {
    if (widget.subject.modulesList.isEmpty) return [];
    return widget.subject.modulesList[_currentModuleIndex]['meetings'] ?? [];
  }

 @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final role = user?['role'] == 'teacher' ? 'Guru' : 'Siswa';
    final themeProvider = context.watch<ThemeProvider>();

    String namaJurusan = 'UMUM';
    if (user?['student']?['classroom']?['department']?['code'] != null) {
      namaJurusan = user!['student']['classroom']['department']['code'];
    }

    // ── EKSTRAKSI DATA DETAIL MODUL AKTIF ──
    // 1. Definisikan dulu currentModule-nya
    final hasModules = widget.subject.modulesList.isNotEmpty;
    final currentModule = hasModules ? widget.subject.modulesList[_currentModuleIndex] : null;

    // 2. BARU SETELAH ITU ambil info semester & target kelasnya
    final String semesterModul = currentModule != null ? (currentModule['semester'] ?? '-') : '-';
    final String targetKelas = currentModule != null ? (currentModule['target_audience'] ?? '-') : '-';

    // 3. Ambil data list lainnya
    final List<String> capaianPembelajaran = currentModule != null && currentModule['learning_achievements'] != null
        ? List<String>.from(currentModule['learning_achievements'])
        : ['Capaian pembelajaran belum diatur oleh guru.'];

    final List<String> tujuanPembelajaran = currentModule != null && currentModule['learning_objectives'] != null
        ? List<String>.from(currentModule['learning_objectives'])
        : ['Tujuan pembelajaran belum diatur oleh guru.'];

    final String pengantar = currentModule != null && currentModule['introduction'] != null
        ? currentModule['introduction']
        : widget.subject.description;
    // ─────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            AppNavbar(
              isDarkMode: themeProvider.isDarkMode,
              onToggleDarkMode: () => themeProvider.toggleTheme(),
              namaRole: role,
              namaJurusan: namaJurusan,
              namaLengkap: user?['name'] ?? 'Pengguna',
              email: user?['email'] ?? '',
              onLogout: () => auth.logout(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(context),
                    const SizedBox(height: 20),
                    _buildMainInfoCard(),
                    const SizedBox(height: 20),
                    // Komponen Judul Modul yang sudah ada Anda...
                    Text(
                      currentModule != null ? currentModule['title'] ?? '' : 'Detail Mata Pelajaran',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    // ── TAMBAHAN BARU: Info Chips Semester & Target Kelas Modul ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('Semester $semesterModul', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.school_rounded, size: 12, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text(targetKelas, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.teal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24), // Beri jarak sebelum masuk ke Card Capaian
                    _buildListCard(
                      title: 'Capaian Pembelajaran',
                      subtitle: 'Apa yang akan kamu kuasai setelah modul ini',
                      icon: Icons.track_changes_rounded,
                      items: capaianPembelajaran, // <--- GUNAKAN VARIABEL LOKAL BARU
                      iconColor: Colors.orange,
                      bulletIcon: Icons.circle,
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'Tujuan Pembelajaran',
                      subtitle: 'Langkah-langkah konkret yang akan dipelajari',
                      icon: Icons.checklist_rounded,
                      items: tujuanPembelajaran, // <--- GUNAKAN VARIABEL LOKAL BARU
                      iconColor: Colors.green,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextCard(
                      title: 'Pengantar',
                      subtitle: 'Pengenalan singkat mengenai modul',
                      icon: Icons.auto_awesome_rounded,
                      contentText: pengantar, // <--- GUNAKAN VARIABEL LOKAL BARU
                    ),
                    const SizedBox(height: 32),
                    _buildSesiPertemuanAccordion(),
                    const SizedBox(height: 24),
                    _buildModuleNavigationRow(), // Tombol navigasi linier bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Kembali ke dashboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGET: Main Info Card (Fokus Informasi Modul Aktif)
  // ─────────────────────────────────────────────
  Widget _buildMainInfoCard() {
    final int pct = (widget.subject.progress * 100).round();
    final hasModules = widget.subject.modulesList.isNotEmpty;
    
    // Mendapatkan data riil dari modul yang sedang aktif dibuka
    final currentModTitle = hasModules ? widget.subject.modulesList[_currentModuleIndex]['title'] : widget.subject.title;
    final int lessonsCount = hasModules ? (widget.subject.modulesList[_currentModuleIndex]['lessons_count'] ?? 3) : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: widget.subject.iconBgColor, shape: BoxShape.circle),
                child: Icon(widget.subject.icon, size: 30, color: widget.subject.iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MODUL ${_currentModuleIndex + 1}', // Penomoran Modul Otomatis
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryText, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentModTitle,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _buildChip('Kode: ${widget.subject.category}'), // Kode Mapel Riil
                        _buildChip('$lessonsCount Pertemuan', icon: Icons.menu_book_rounded),
                        _buildChip('±10 jam', icon: Icons.access_time_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                child: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isBookmarked ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Pengampu: Ahmad Supriyanto, S.Kom.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progres Penyelesaian Modul', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('$pct%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: widget.subject.progress,
              backgroundColor: AppColors.progressBg,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            // PERBAIKAN: Otomatis mencari pertemuan terdekat yang belum selesai
            onPressed: () {
              final meetings = _currentMeetings;
              if (meetings.isEmpty) return;

              int targetIndex = 0; // Default ke pertemuan pertama jika semua sudah selesai

              // Melakukan looping untuk mencari pertemuan pertama yang statusnya BUKAN 'completed'
              for (int i = 0; i < meetings.length; i++) {
                if (meetings[i]['status'] != 'completed') {
                  targetIndex = i;
                  break;
                }
              }

              setState(() {
                _expandedMeetingIndex = targetIndex; // Otomatis membuka dropdown pertemuan tersebut
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Lanjutkan modul', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGET: Universal Expandable Card (Default Ter-tutup / Closed)
  // ─────────────────────────────────────────────
  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false, // PERBAIKAN: Default close sesuai instruksi
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: iconColor, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Container(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> items,
    required Color iconColor,
    IconData? bulletIcon,
    bool isNumeric = false,
  }) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNumeric)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20, height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Text('${index + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: iconColor)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(bulletIcon ?? Icons.circle, color: iconColor, size: 10),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text, style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.5)),
              ),
            ],
          ),
        );
      }).toList(),
    );

    return _buildExpandableCard(title: title, subtitle: subtitle, icon: icon, iconColor: iconColor, content: content);
  }

  Widget _buildTextCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String contentText,
  }) {
    Widget content = Text(contentText, style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.6));
    return _buildExpandableCard(title: title, subtitle: subtitle, icon: icon, iconColor: Colors.purple, content: content);
  }

  // ─────────────────────────────────────────────
  //  WIDGET: Akordion Sesi Kelas / Pertemuan (Merespons Sinyal Ekspansi Otomatis)
  // ─────────────────────────────────────────────
  Widget _buildSesiPertemuanAccordion() {
    final meetings = _currentMeetings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sesi Kelas / Pertemuan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        if (meetings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('Belum ada jadwal sesi kelas untuk rombel Anda.')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meetings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
            final pertemuan = meetings[index];
            final lessons = pertemuan['lessons'] as List;

            // Ambil data semester pertemuan (pastikan aman dari huruf besar/kecil dengan toLowerCase)
            final String semSesi = (pertemuan['semester'] ?? '').toString().toLowerCase();
            final bool isGanjil = semSesi == 'ganjil';

            // ── TAMBAHKAN BARIS INI: Format judul dengan index (dimulai dari 0 + 1) ──
            final String formattedTitle = 'Pertemuan ${index + 1} - ${pertemuan['title'] ?? ''}';

              return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
              ),
                child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: UniqueKey(),
                  initiallyExpanded: _expandedMeetingIndex == index,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedMeetingIndex = expanded ? index : null;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  collapsedIconColor: AppColors.textMuted,
                  iconColor: AppColors.primary,
                    title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          formattedTitle, 
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge Indikator Semester Sesi Kelas
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGanjil ? Colors.blue.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isGanjil ? Colors.blue.withValues(alpha: 0.2) : Colors.purple.withValues(alpha: 0.2))
                        ),
                        child: Text(
                          isGanjil ? 'GANJIL' : 'GENAP',
                          style: TextStyle(
                            fontSize: 9, 
                            fontWeight: FontWeight.w900, 
                            color: isGanjil ? Colors.blue : Colors.purple,
                            letterSpacing: 0.3
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  subtitle: Text('${lessons.length} Materi Pembelajaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  children: [
                      Container(height: 1, color: AppColors.border),
                      ...lessons.map((lesson) {
                        IconData typeIcon;
                        Color typeColor;

                        switch (lesson['type']) {
                          case 'video': typeIcon = Icons.play_circle_fill_rounded; typeColor = AppColors.primary; break;
                          case 'quiz': typeIcon = Icons.quiz_rounded; typeColor = Colors.orange; break;
                          case 'task': typeIcon = Icons.assignment_rounded; typeColor = Colors.purple; break;
                          default: typeIcon = Icons.description_rounded; typeColor = Colors.teal;
                        }

                        return _LessonListTile(
                          lesson: lesson,
                          typeIcon: typeIcon,
                          typeColor: typeColor,
                          onTap: () => _showMaterialBottomSheet(context, lesson, typeIcon, typeColor),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // Widget Pop-up Viewer Materi Dinamis sesuai tipe konten database
  String? _extractYouTubeId(String url) {
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  // ── WIDGET BARU: Modern Bottom Sheet Viewer ──
  void _showMaterialBottomSheet(BuildContext context, Map<String, dynamic> lesson, IconData icon, Color color) {
    final String type = lesson['type'] ?? 'document';
    final String description = lesson['description'] ?? 'Tidak ada deskripsi tambahan untuk materi ini.';
    final String? url = lesson['content_url'];
    final String? file = lesson['attachment_path'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Memungkinkan Bottom Sheet ditarik hingga atas
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          // Tinggi maksimal 85% dari layar agar masih terlihat konteks halaman di belakangnya
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis penanda bisa digeser (Handle Bar)
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header Materi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson['title'] ?? 'Detail Aktivitas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Tutup (X)
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 20),

              // Area Konten yang Bisa Digulir
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instruksi / Isi Materi:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text(description, style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                      const SizedBox(height: 32),

                      // 🛠️ KONDISIONAL UI: Jika tipe konten adalah VIDEO YouTube
                      if (type == 'video' && url != null) ...[
                        Builder(
                          builder: (context) {
                            final String? videoId = _extractYouTubeId(url);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Video Pembelajaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                                const SizedBox(height: 12),
                                if (videoId != null)
                                  // ── GANTI DI SINI: Langsung panggil Player Interaktif ──
                                  _LmsYoutubePlayer(videoId: videoId)
                                else
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                                    child: Text('Tautan video bukan format YouTube standar:\n$url', style: TextStyle(color: AppColors.textPrimary)),
                                  ),
                              ],
                            );
                          }
                        ),
                      ],

                      // 🛠️ KONDISIONAL UI: Jika tipe konten adalah DOKUMEN atau TUGAS
                      if ((type == 'document' || type == 'task') && file != null) ...[
                        Text('Lampiran Berkas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08), 
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.picture_as_pdf_rounded, color: color, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(file.split('/').last, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('Dokumen Pendukung', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.download_rounded, color: color, size: 26),
                                onPressed: () {}, // Kelak ditautkan ke package downloader file
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 🛠️ KONDISIONAL UI: Jika tipe konten adalah KUIS
                      if (type == 'quiz') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_turned_in_rounded, color: color, size: 48),
                              const SizedBox(height: 16),
                              Text('Evaluasi Ujian Mandiri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              Text('Siapkan diri Anda sebelum memulai kuis ini.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color, foregroundColor: Colors.white, elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text('Mulai Kerjakan Kuis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGET: Baris Navigasi Linier Modul (Sesuai Batas Indeks Database)
  // ─────────────────────────────────────────────
  Widget _buildModuleNavigationRow() {
    final int totalModules = widget.subject.modulesList.length;
    final bool hasPrevious = _currentModuleIndex > 0;
    final bool hasNext = _currentModuleIndex < totalModules - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Modul Sebelumnya
          if (hasPrevious)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentModuleIndex--;
                    _expandedMeetingIndex = null; // Reset ekspansi saat pindah modul
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Modul Sebelumnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 10),

          // Tombol Tengah: List Modul Pop-up
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showJumpToModuleDialog,
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text('List Modul', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Tombol Selanjutnya
          if (hasNext)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentModuleIndex++;
                    _expandedMeetingIndex = null;
                  });
                },
                label: const Text('Selanjutnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  // Bottom Sheet untuk melakukan lompatan (jumping) modul secara instan
  void _showJumpToModuleDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daftar Keseluruhan Modul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.subject.modulesList.length,
                  itemBuilder: (context, index) {
                    final mod = widget.subject.modulesList[index];
                    final bool isCurrent = index == _currentModuleIndex;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? AppColors.primary : AppColors.background,
                        child: Text('${index + 1}', style: TextStyle(color: isCurrent ? Colors.white : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(mod['title'] ?? '', style: TextStyle(fontSize: 14, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, color: AppColors.textPrimary)),
                      trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20) : null,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentModuleIndex = index;
                          _expandedMeetingIndex = null;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET BARU: Pemutar YouTube Internal LMS (Versi 10.x.x)
// ─────────────────────────────────────────────
class _LmsYoutubePlayer extends StatefulWidget {
  final String videoId;
  const _LmsYoutubePlayer({required this.videoId});

  @override
  State<_LmsYoutubePlayer> createState() => _LmsYoutubePlayerState();
}

class _LmsYoutubePlayerState extends State<_LmsYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ── REFAKTOR v10.0.1: Menggunakan sintaks dari iFrame API ──
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true, // Opsional: membatasi video terkait
      ),
    );
  }

  @override
  void deactivate() {
    // ── REFAKTOR v10.0.1: Menggunakan pauseVideo() alih-alih pause() ──
    _controller.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    // Menutup controller untuk mencegah memory leak
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      // ── REFAKTOR v10.0.1: Properti lebih ringkas menggunakan aspectRatio ──
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET BARU: List Item Interaktif dengan Checkbox
// ─────────────────────────────────────────────
class _LessonListTile extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final IconData typeIcon;
  final Color typeColor;
  final VoidCallback onTap;

  const _LessonListTile({
    required this.lesson,
    required this.typeIcon,
    required this.typeColor,
    required this.onTap,
  });

  @override
  State<_LessonListTile> createState() => _LessonListTileState();
}

class _LessonListTileState extends State<_LessonListTile> {
  // State lokal sementara (nanti akan dihubungkan dengan data riil API)
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.typeColor.withValues(alpha: 0.1), 
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(widget.typeIcon, size: 20, color: widget.typeColor),
      ),
      title: Text(
        widget.lesson['title'] ?? '',
        style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.w600, 
          // Jika selesai, warna agak pudar. Jika belum, warna tegas.
          color: _isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
          // Efek coret saat materi diselesaikan
          decoration: _isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: AppColors.textSecondary,
        ),
      ),
      // ── AREA CHECKBOX KUSTOM ──
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            _isCompleted = !_isCompleted;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isCompleted ? Colors.green : Colors.transparent,
            border: Border.all(
              color: _isCompleted ? Colors.green : AppColors.textMuted.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: _isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
      onTap: widget.onTap,
    );
  }
}