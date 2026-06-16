// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/course_model.dart';
import '../../providers/course_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).getCourses();
    });
  }

  // Maps department strings to specific Material icons
  IconData _getDepartmentIcon(String departmentName) {
    switch (departmentName) {
      case 'Teknik Komputer & Jaringan':
        return Icons.lan_outlined;
      case 'Rekayasa Perangkat Lunak':
        return Icons.code;
      case 'Multimedia':
        return Icons.color_lens_outlined;
      case 'Teknik Mesin':
        return Icons.precision_manufacturing_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 600 || MediaQuery.of(context).orientation == Orientation.landscape;

      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Consumer<CourseProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.courses.isEmpty) {
                return const Center(child: Text('Belum ada data modul.'));
              }

              // Extract the first course as the active "Continuing" module
              final Course activeCourse = provider.courses.first;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverHeader(),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: 16),
                          _buildContinuingModuleCard(isWide, activeCourse), 
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildModuleLibraryLabel(provider.courses.length),
                    ),
                  ];
                },
                body: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      sliver: _buildResponsiveModuleGrid(provider.courses, isWide, constraints.maxWidth),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
    });
  }

  Widget _buildSliverHeader() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SMK Belajar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                    ),
                    Text(
                      'Modul Pembelajaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Adi Pratama',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'XI TKJ • SMKN 1',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: const Text('AP', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF7E6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_fire_department, color: Color(0xFFFCB700), size: 16),
                SizedBox(width: 4),
                Text('5 hari beruntun', style: TextStyle(color: Color(0xFFFCB700), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              text: 'Selamat datang, ',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5),
              children: <TextSpan>[
                TextSpan(text: 'Adi 👋', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ayo lanjutkan perjalanan belajarmu hari ini. Konsistensi kecil setiap hari membentuk keahlian besar.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
          ),
        ],
      ),
    );
  }

  // Accepts dynamic Course object to populate data
  Widget _buildContinuingModuleCard(bool isWide, Course course) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        bool isCardWide = constraints.maxWidth > 500;
        final IconData courseIcon = _getDepartmentIcon(course.departmentName);
        final String courseSubtitle = "${course.departmentName} • ${course.gradeLevel}";
        final String progressLabel = "${course.completedLessons} dari ${course.totalLessons} pelajaran selesai";

        return Card(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: .1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: isCardWide
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCardHeader("LANJUTKAN BELAJAR"),
                            const SizedBox(height: 8),
                            Text(
                              course.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              courseSubtitle,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            _buildProgressBar(course.progress, progressLabel),
                            const SizedBox(height: 20),
                            _buildContinueButton(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildLargeModuleIcon(courseIcon, Colors.blue),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader("LANJUTKAN BELAJAR"),
                      const SizedBox(height: 12),
                      Text(
                        course.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        courseSubtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(course.progress, progressLabel),
                      const SizedBox(height: 20),
                      _buildContinueButton(),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildCardHeader(String text) {
    return Row(
      children: [
        const Icon(Icons.book, size: 14, color: Colors.blue),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }

  Widget _buildProgressBar(double value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Progres keseluruhan", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.blue[50],
          color: Colors.blue,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 117, 117, 117))),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Lanjutkan pelajaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }

  Widget _buildLargeModuleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  Widget _buildModuleLibraryLabel(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Pustaka Modul", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("$count modul", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveModuleGrid(List<Course> courses, bool isWide, double maxWidth) {
    int crossAxisCount = 1;
    double childAspectRatio = 1.0;

    if (maxWidth > 900) {
      crossAxisCount = 3; 
      childAspectRatio = 1.1; 
    } else if (maxWidth > 600 || isWide) {
      crossAxisCount = 2; 
      childAspectRatio = 1.0; 
    } else {
      crossAxisCount = 1; 
      childAspectRatio = 1.3; 
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final course = courses[index];
          
          return _buildModuleCard(
            index: index,
            title: course.title,
            description: course.description,
            departmentName: course.departmentName,
            gradeLevel: course.gradeLevel,
            icon: _getDepartmentIcon(course.departmentName),
            progress: course.progress,
            completedLessons: course.completedLessons,
            totalLessons: course.totalLessons,
          );
        },
        childCount: courses.length,
      ),
    );
  }

  // Accepts exact data mapping via Course object bounds
  Widget _buildModuleCard({
    required int index,
    required String title,
    required String description,
    required String departmentName,
    required String gradeLevel,
    required IconData icon,
    required double progress,
    required int completedLessons,
    required int totalLessons,
  }) {
    final List<Color> cardIconColors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red
    ];
    final Color currentIconColor = cardIconColors[index % cardIconColors.length];
    final Color currentBgIconColor = currentIconColor.withValues(alpha: 0.1);

    return LayoutBuilder(builder: (context, constraints) {
      bool isCardNarrow = constraints.maxWidth < 250;
      double iconSize = isCardNarrow ? 30 : 40;
      double containerSize = isCardNarrow ? 60 : 70;

      return Card(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: currentBgIconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: currentIconColor, size: iconSize),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(gradeLevel, style: TextStyle(fontSize: 10, color: Colors.blue[900], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(departmentName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$completedLessons/$totalLessons pelajaran", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: currentBgIconColor,
                color: currentIconColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_), label: 'Modul'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), activeIcon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}