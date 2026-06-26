// lib/ui/screens/widgets/app_navbar.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppNavbar extends StatefulWidget {
  const AppNavbar({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.namaRole,
    required this.namaJurusan,
    required this.onLogout,
    this.namaLengkap = 'Pengguna',
    this.email = '',
  });

  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final String namaRole;
  final String namaJurusan;
  final VoidCallback onLogout;
  final String namaLengkap;
  final String email;

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  final GlobalKey _avatarKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _menuOpen = false;

  void _toggleMenu() {
    if (_menuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final renderBox = _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeMenu,
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: _ProfileDropdown(
              namaLengkap: widget.namaLengkap,
              email: widget.email,
              onProfil: () {
                _closeMenu();
              },
              onPustakaModul: () {
                _closeMenu();
              },
              onKeluar: () {
                _closeMenu();
                widget.onLogout();
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _menuOpen = true);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _menuOpen = false);
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  String get _inisial {
    final parts = widget.namaLengkap.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LMS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  'Platform Edukasi Terpadu',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            
            // ── TOMBOL TEMA (DARK / LIGHT MODE) ──
            GestureDetector(
              onTap: widget.onToggleDarkMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  // Jika dark mode, warna abu-abu gelap. Jika light mode, kuning
                  color: widget.isDarkMode ? const Color(0xFF334155) : const Color(0xFFFACC15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ─────────────────────────────────────

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.chipBorder),
              ),
              child: Text(
                widget.namaRole.toUpperCase(),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.namaJurusan.toUpperCase(),
                style: TextStyle( // <--- HAPUS KATA 'const' DI SINI
                  color: AppColors.primaryText, // <--- UBAH MENJADI primaryText
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              key: _avatarKey,
              onTap: _toggleMenu,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _menuOpen
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                      : [],
                ),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _inisial,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.namaLengkap,
    required this.email,
    required this.onProfil,
    required this.onPustakaModul,
    required this.onKeluar,
  });

  final String namaLengkap;
  final String email;
  final VoidCallback onProfil;
  final VoidCallback onPustakaModul;
  final VoidCallback onKeluar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaLengkap, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(email, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 4),
            _ProfileMenuItem(icon: Icons.person_outline_rounded, label: 'Profil', onTap: onProfil),
            _ProfileMenuItem(icon: Icons.grid_view_rounded, label: 'Pustaka Modul', onTap: onPustakaModul),
            const SizedBox(height: 4),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 4),
            _ProfileMenuItem(icon: Icons.logout_rounded, label: 'Keluar', onTap: onKeluar, isDestructive: true),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatefulWidget {
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool isDestructive;
  @override State<_ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<_ProfileMenuItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? Colors.red : AppColors.textPrimary;
    final hoverBg = widget.isDestructive ? Colors.red.withValues(alpha: 0.06) : AppColors.background;
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true), onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120), margin: const EdgeInsets.symmetric(horizontal: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: _hovered ? hoverBg : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [Icon(widget.icon, size: 17, color: color), const SizedBox(width: 10), Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color))]),
        ),
      ),
    );
  }
}