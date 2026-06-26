<?php

namespace Database\Seeders;

use App\Models\Classroom;
use App\Models\ClassSession;
use App\Models\ClassSessionMaterial;
use App\Models\Department;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\TeachingModule;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $defaultPassword = Hash::make('123');
        $now = Carbon::now();

        // ──────────────────────────────────────────────────
        // 1. DEPARTEMEN
        // ──────────────────────────────────────────────────

        $rpl = Department::factory()->create([
            'code' => 'RPL',
            'name' => 'Rekayasa Perangkat Lunak',
        ]);

        $tkj = Department::factory()->create([
            'code' => 'TKJ',
            'name' => 'Teknik Komputer & Jaringan',
        ]);

        $mm = Department::factory()->create([
            'code' => 'MM',
            'name' => 'Multimedia / DKV',
        ]);

        // ──────────────────────────────────────────────────
        // 2. KELAS (ROMBEL)
        // ──────────────────────────────────────────────────

        $classXiRpl = Classroom::create([
            'department_id' => $rpl->id,
            'grade_level'   => 'Kelas XI',
            'name'          => 'XI RPL 1',
        ]);

        $classXiTkj = Classroom::create([
            'department_id' => $tkj->id,
            'grade_level'   => 'Kelas XI',
            'name'          => 'XI TKJ 1',
        ]);

        // ──────────────────────────────────────────────────
        // 3. USER — Admin
        // ──────────────────────────────────────────────────

        $adminUser = User::factory()->create([
            'name'     => 'System Administrator',
            'email'    => 'admin@lms.local',
            'password' => $defaultPassword,
        ]);

        // ──────────────────────────────────────────────────
        // 4. USER — Guru & Profil Teacher
        // ──────────────────────────────────────────────────

        $teacherUser1 = User::factory()->create([
            'name'     => 'Nur Falah Ramadan',
            'email'    => 'guru.rpl@lms.local',
            'password' => $defaultPassword,
        ]);

        $teacherRpl = Teacher::factory()->create([
            'user_id'           => $teacherUser1->id,
            'nip'               => '198001012005011003',
            'employment_status' => 'PNS',
            'ptk_type'          => 'Guru Mata Pelajaran',
            'department_id'     => $rpl->id,
        ]);

        $teacherUser2 = User::factory()->create([
            'name'     => 'Zainal Arifin',
            'email'    => 'guru.tkj@lms.local',
            'password' => $defaultPassword,
        ]);

        $teacherTkj = Teacher::factory()->create([
            'user_id'           => $teacherUser2->id,
            'nip'               => '198203042008011005',
            'employment_status' => 'GTY',
            'ptk_type'          => 'Guru Mata Pelajaran',
            'department_id'     => $tkj->id,
        ]);

        // ──────────────────────────────────────────────────
        // 5. USER — Siswa & Profil Student
        // ──────────────────────────────────────────────────

        $studentUser1 = User::factory()->create([
            'name'     => 'Bahlil',
            'email'    => 'siswa@lms.local',
            'password' => $defaultPassword,
        ]);

        Student::factory()->create([
            'user_id'         => $studentUser1->id,
            'nisn'            => '0051234567',
            'nis'             => '25001',
            'enrollment_year' => 2025,
            'department_id'   => $rpl->id,
            'classroom_id'    => $classXiRpl->id,
        ]);

        $studentUser2 = User::factory()->create([
            'name'     => 'Shofia Nabila Ramah',
            'email'    => 'shofia@lms.local',
            'password' => $defaultPassword,
        ]);

        Student::factory()->create([
            'user_id'         => $studentUser2->id,
            'nisn'            => '0057654321',
            'nis'             => '25002',
            'enrollment_year' => 2025,
            'department_id'   => $tkj->id,
            'classroom_id'    => $classXiTkj->id,
        ]);

        // ──────────────────────────────────────────────────
        // 6. MATA PELAJARAN & RELASI PIVOT GURU
        // ──────────────────────────────────────────────────

        $subjectPwpb = Subject::factory()->create([
            'code'        => 'PWPB',
            'name'        => 'Pemrograman Web dan Perangkat Bergerak',
            'grade_level' => 'Kelas XI',
            'department_id' => $rpl->id,
        ]);

        $subjectAij = Subject::factory()->create([
            'code'        => 'AIJ',
            'name'        => 'Administrasi Infrastruktur Jaringan',
            'grade_level' => 'Kelas XI',
            'department_id' => $tkj->id,
        ]);

        $teacherRpl->subjects()->attach($subjectPwpb->id, [
            'is_verified' => true,
            'verified_by' => $adminUser->id,
        ]);

        $teacherTkj->subjects()->attach($subjectAij->id, [
            'is_verified' => true,
            'verified_by' => $adminUser->id,
        ]);

        // ──────────────────────────────────────────────────
        // 7. MODUL PEMBELAJARAN
        // ──────────────────────────────────────────────────

        $moduleLaravel = TeachingModule::create([
            'subject_id'             => $subjectPwpb->id,
            'teacher_id'             => $teacherRpl->id,
            'title'                  => 'Memahami Arsitektur MVC pada Laravel',
            'introduction'           => 'Modul ini fokus pada pemahaman pola desain Model-View-Controller menggunakan framework Laravel untuk membangun Platform Riset & Gerai Ekonomi Lokal (PRIGEL).',
            'learning_achievements'  => "Peserta didik mampu merancang struktur database relasional.\nPeserta didik menguasai implementasi routing dan controller.",
            'learning_objectives'    => "Mendefinisikan konsep Model, View, Controller.\nMembuat sistem CRUD sederhana terintegrasi dengan antarmuka web.",
            'general_information'    => [
                'semester'          => 'Ganjil',
                'target_audience'   => 'Siswa Kelas XI RPL',
                'learning_approach' => 'Project-based Learning (PjBL)',
                'theories'          => ['Konstruktivistik', 'Kognitif'],
            ],
            'core_components' => [
                ['chapter' => 'Bab 1', 'title' => 'Konsep Dasar MVC',              'description' => 'Analogi MVC dengan sistem kerja restoran mewah.'],
                ['chapter' => 'Bab 2', 'title' => 'Blade Template & View',         'description' => 'Tampilan antarmuka dengan Blade.'],
                ['chapter' => 'Bab 3', 'title' => 'Integrasi UI dengan Flutter',   'description' => 'Menghubungkan API Laravel dengan state management di Flutter.'],
            ],
            'attachments' => [
                'assessment_type' => 'Proyek Interaktif',
                'files'           => [],
            ],
        ]);

        $moduleCisco = TeachingModule::create([
            'subject_id'             => $subjectAij->id,
            'teacher_id'             => $teacherTkj->id,
            'title'                  => 'Simulasi Routing dengan Cisco Packet Tracer',
            'introduction'           => 'Modul ini memberikan pemahaman mendalam tentang perancangan topologi jaringan dan penghitungan subnetting VLSM.',
            'learning_achievements'  => "Peserta didik mampu menghitung pembagian IP dengan metode VLSM.\nPeserta didik mampu mengkonfigurasi static dan dynamic routing.",
            'learning_objectives'    => "Mensimulasikan jaringan kompleks di Cisco Packet Tracer.\nMengidentifikasi jalur routing optimal antar router.",
            'general_information'    => [
                'semester'          => 'Ganjil',
                'target_audience'   => 'Siswa Kelas XI TKJ',
                'learning_approach' => 'Problem-based Learning',
                'theories'          => ['Behavioristik'],
            ],
            'core_components' => [
                ['chapter' => 'Bab 1', 'title' => 'Konsep Subnetting VLSM', 'description' => 'Teknik pemecahan IP Address sesuai kebutuhan host.'],
                ['chapter' => 'Bab 2', 'title' => 'Topografi Jaringan',      'description' => 'Desain arsitektur LAN dan WAN dasar.'],
            ],
            'attachments' => [
                'assessment_type' => 'Ujian Praktik Simulasi',
                'files'           => [],
            ],
        ]);

        // ──────────────────────────────────────────────────
        // 8. SESI KELAS (JADWAL)
        // ──────────────────────────────────────────────────

        $session1 = ClassSession::create([
            'teacher_id'         => $teacherRpl->id,
            'subject_id'         => $subjectPwpb->id,
            'classroom_id'       => $classXiRpl->id,
            'teaching_module_id' => $moduleLaravel->id,
            'academic_year_start'=> 2026,
            'semester'           => 'ganjil',
            'meeting_number'     => 1,
            'title'              => 'Pengenalan Routing dan View Laravel',
            'type'               => 'regular',
            'method'             => 'hybrid',
            'scheduled_at'       => $now->copy()->addDays(2),
            'status'             => 'scheduled',
            'teacher_notes'      => null,
        ]);

        $session2 = ClassSession::create([
            'teacher_id'         => $teacherTkj->id,
            'subject_id'         => $subjectAij->id,
            'classroom_id'       => $classXiTkj->id,
            'teaching_module_id' => $moduleCisco->id,
            'academic_year_start'=> 2026,
            'semester'           => 'ganjil',
            'meeting_number'     => 1,
            'title'              => 'Desain Topologi Cisco',
            'type'               => 'regular',
            'method'             => 'offline',
            'scheduled_at'       => $now->copy()->addDays(3),
            'status'             => 'scheduled',
            'teacher_notes'      => null,
        ]);

        // ──────────────────────────────────────────────────
        // 9. MATERI SESI KELAS
        // ──────────────────────────────────────────────────

        ClassSessionMaterial::create([
            'class_session_id' => $session1->id,
            'title'            => 'Pengantar Arsitektur MVC',
            'type'             => 'video',
            'description'      => 'Silakan tonton penjelasan arsitektur ini sebelum kelas tatap muka dimulai untuk bahan diskusi.',
            'content_url'      => 'https://www.youtube.com/watch?v=1234567890',
            'attachment_path'  => null,
            'quiz_id'          => null,
        ]);

        ClassSessionMaterial::create([
            'class_session_id' => $session1->id,
            'title'            => 'Dokumentasi API PRIGEL',
            'type'             => 'document',
            'description'      => 'Baca dokumentasi rancangan endpoint yang akan kita bangun.',
            'content_url'      => null,
            'attachment_path'  => 'class-session-attachments/dummy-doc.pdf',
            'quiz_id'          => null,
        ]);

        ClassSessionMaterial::create([
            'class_session_id' => $session2->id,
            'title'            => 'Tugas Rancang VLSM',
            'type'             => 'task',
            'description'      => 'Buatlah skema pembagian subnet VLSM untuk 4 divisi: HRD (10 host), Keuangan (25 host), IT (50 host), dan Publik (100 host).',
            'content_url'      => null,
            'attachment_path'  => null,
            'quiz_id'          => null,
        ]);
    }
}
