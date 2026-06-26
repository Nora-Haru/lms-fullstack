import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/module_item.dart';
import '../subject_detail_screen.dart'; // Impor rute navigasi

// ─────────────────────────────────────────────
//  Komponen Section & Card
// ─────────────────────────────────────────────
class WelcomeSection extends StatelessWidget {
  final String nama;
  const WelcomeSection({super.key, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('Online hari ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.badgeText)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
            children: [
              const TextSpan(text: 'Selamat datang, '),
              TextSpan(text: nama, style: TextStyle(color: AppColors.primary)),
              const TextSpan(text: ' 👋'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Ayo lanjutkan perjalanan belajarmu hari ini.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }
}

class ContinueLearningCard extends StatelessWidget {
  final ModuleItem module;
  const ContinueLearningCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final int pct = (module.progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('MODUL TERBARU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          Text(module.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text('${module.category} • ${module.grade}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progres modul', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('$pct%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: module.progress,
              backgroundColor: AppColors.progressBg,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const SizedBox.shrink(),
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mulai pelajaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari modul atau mata pelajaran...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({super.key, required this.items, required this.selected, required this.activeColor, required this.onTap});
  final List<String> items;
  final String selected;
  final Color activeColor;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = item == selected;
          return GestureDetector(
            onTap: () => onTap(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? activeColor : AppColors.chipBorder),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyModuleState extends StatelessWidget {
  const EmptyModuleState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.folder_open_rounded, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Belum ada modul tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Modul untuk jurusanmu belum ditambahkan.\nSilakan hubungi guru atau admin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject});
  final ModuleItem subject; 

  void _showModuleSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Pilih Modul Pembelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Pilih modul dari ${subject.title} yang ingin kamu pelajari.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              if (subject.modulesList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Belum ada modul untuk mata pelajaran ini.')),
                )
              else
                ...subject.modulesList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mod = entry.value;
                  final isActive = index == 0; 
                  
                  // ── UBAH DI SINI: Sisipkan "Modul [nomor]: " di depan judul ──
                  final formattedTitle = 'Modul ${index + 1}: ${mod['title']}';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBottomSheetItem(
                      context, 
                      formattedTitle, 
                      '${mod['lessons_count']} Sesi Materi', 
                      isActive,
                      index, // 👈 1. Lempar variabel index ke fungsi di bawah
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(BuildContext context, String title, String subtitle, bool isActive, int index) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); 
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(subject: subject, initialModuleIndex: index)));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: isActive ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isActive ? AppColors.primaryLight : AppColors.background, shape: BoxShape.circle),
              child: Icon(Icons.menu_book_rounded, color: isActive ? AppColors.primary : AppColors.textMuted, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pct = (subject.progress * 100).round();
    return GestureDetector(
      onTap: () => _showModuleSelection(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER CARD ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: subject.iconBgColor, shape: BoxShape.circle),
                  child: Icon(subject.icon, color: subject.iconColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.gradeChip, borderRadius: BorderRadius.circular(12)),
                  child: Text(subject.grade, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gradeChipText)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ── IDENTITAS MAPEL ──
            Text(
              subject.category.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subject.title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              subject.description,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 14),

            // ── INFORMASI EKSTRA (PENGAMPU & JADWAL) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ahmad Supriyanto, S.Kom.', // Dummy, nanti bisa pakai subject.teacherName jika API diupdate
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Senin • 07:30 - 09:00 WIB', // Dummy
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(), // Mendorong sisa ruang agar Progress Bar tetap di dasar

            // ── PROGRESS BAR ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${subject.completed}/${subject.total} modul', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.progress,
                backgroundColor: AppColors.progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}