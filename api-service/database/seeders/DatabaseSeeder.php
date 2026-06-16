<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Course;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Classroom;
use App\Models\Department;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\TeachingModule;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();
        Course::factory(10)->create();

        $defaultPassword = Hash::make('123');

        // 1. Inisialisasi Departemen & Kelas
        $tkj = Department::create(['code' => 'TKJ', 'name' => 'Teknik Komputer & Jaringan']);
        $rpl = Department::create(['code' => 'RPL', 'name' => 'Rekayasa Perangkat Lunak']);
        $dkv = Department::create(['code' => 'DKV', 'name' => 'Desain Komunikasi Visual']);

        $classXiTkj = Classroom::create(['department_id' => $tkj->id, 'grade_level' => 'Kelas XI', 'name' => 'XI TKJ 1']);

        // 2. Inisialisasi Kredensial Global (Users)
        $adminUser = User::create([
            'name' => 'System Administrator',
            'email' => 'admin@lms.local',
            'password' => $defaultPassword,
        ]);

        $teacherUser = User::create([
            'name' => 'Nur Falah Ramadan',
            'email' => 'teacher@lms.local',
            'password' => $defaultPassword,
        ]);

        $studentUser = User::create([
            'name' => 'Adi Pratama',
            'email' => 'student@lms.local',
            'password' => $defaultPassword,
        ]);

        // 3. Inisialisasi Profil Entitas Spesifik (Delegation Pattern)
        $teacherProfile = Teacher::create([
            'user_id' => $teacherUser->id,
            'nip' => '198001012005011003',
            'employment_status' => 'PNS',
            'ptk_type' => 'Guru Mata Pelajaran',
            'department_id' => $rpl->id,
        ]);

        Student::create([
            'user_id' => $studentUser->id,
            'nisn' => '0051234567',
            'nis' => '25001',
            'enrollment_year' => 2025,
            'department_id' => $tkj->id,
            'classroom_id' => $classXiTkj->id,
        ]);

        // 4. Inisialisasi Relasi Akademik & Verifikasi Pivot
        $subjectPwpb = Subject::create([
            'code' => 'PWPB',
            'name' => 'Pemrograman Web dan Perangkat Bergerak',
            'grade_level' => 'Kelas XI',
        ]);

        $teacherProfile->subjects()->attach($subjectPwpb->id, [
            'is_verified' => true,
            'verified_by' => $adminUser->id,
        ]);

        // 5. Integrasi Dokumen Strategi Pembelajaran (Teaching Module JSON)
        TeachingModule::create([
            'subject_id' => $subjectPwpb->id,
            'teacher_id' => $teacherProfile->id,
            'title' => 'Memahami Arsitektur MVC pada Laravel',
            'general_information' => [
                'semester' => 2,
                'target_audience' => 'Siswa Kelas XI',
                'learning_approach' => 'Project-based Learning (PjBL)',
                'theories' => ['Behavioristik', 'Kognitif', 'Konstruktivistik']
            ],
            'core_components' => [
                [
                    'chapter' => 'Bab 1',
                    'title' => 'Konsep Dasar MVC',
                    'description' => 'Analogi MVC dengan sistem kerja restoran mewah.'
                ],
                [
                    'chapter' => 'Bab 2',
                    'title' => 'View (Tampilan Antarmuka)',
                    'description' => 'Penggunaan Blade Template Engine dan Separation of Concerns.'
                ],
                [
                    'chapter' => 'Bab 3',
                    'title' => 'Model',
                    'description' => 'Interaksi pangkalan data menggunakan Eloquent ORM.'
                ],
                [
                    'chapter' => 'Bab 4',
                    'title' => 'Controller',
                    'description' => 'Penerimaan request dan pengatur lalu lintas data.'
                ]
            ],
            'attachments' => [
                'assessment_type' => 'Uraian & Proyek Profil Interaktif',
                'files' => []
            ]
        ]);
    }
}
