<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\Student;
use App\Models\ClassSession;
use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StudentDashboardController extends Controller
{
    public function index(Request $request)
    {
        $userId = Auth::id();

        // 1. Cari data siswa berdasarkan user yang sedang login
        $student = Student::where('user_id', $userId)->first();

        if (!$student) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data profil siswa tidak ditemukan.'
            ], 404);
        }

        $classroomId = $student->classroom_id;

        // 2. Ambil Mata Pelajaran (Subject) yang memiliki sesi kelas di rombel siswa tersebut
        $subjects = Subject::all()->map(function ($subject) use ($classroomId, $student) {

            // Ambil semua modul/materi yang terikat dengan mata pelajaran ini
            // Dan muat Sesi Kelas yang dikhususkan untuk Rombel siswa ini beserta isi materinya
            $modulesList = \App\Models\TeachingModule::where('subject_id', $subject->id)
                ->get()
                ->map(function ($module) use ($classroomId, $student) {

                    // Ambil Sesi Kelas riil dari database
                    $sessions = ClassSession::where('teaching_module_id', $module->id)
                        ->where('classroom_id', $classroomId)
                        ->with('materials')
                        ->get();

                    $totalSessions = $sessions->count();

                    // Hitung berapa sesi yang sudah diselesaikan siswa (berdasarkan tabel attendances riil)
                    $completedSessions = $sessions->filter(function ($session) use ($student) {
                        return Attendance::where('class_session_id', $session->id)
                            ->where('student_id', $student->id)
                            ->whereIn('status', ['present', 'late']) // Hadir atau Terlambat dianggap selesai
                            ->exists();
                    })->count();

                    return [
                        'id' => $module->id,
                        'title' => $module->title,
                        'lessons_count' => $totalSessions,
                        'completed_count' => $completedSessions,

                        // ── FITUR BARU: Mengirim Data Semester & Target Kelas dari JSON Modul ──
                        'semester' => $module->general_information['semester'] ?? '-',
                        'target_audience' => $module->general_information['target_audience'] ?? '-',

                        'introduction' => $module->introduction ?? 'Pengantar belum tersedia.',
                        'learning_achievements' => $module->learning_achievements ? array_values(array_filter(array_map('trim', explode("\n", $module->learning_achievements)))) : [],
                        'learning_objectives' => $module->learning_objectives ? array_values(array_filter(array_map('trim', explode("\n", $module->learning_objectives)))) : [],

                        'meetings' => $sessions->map(function ($session) {
                            return [
                                'id' => $session->id,
                                'title' => $session->title,
                                'status' => $session->status,
                                'scheduled_at' => $session->scheduled_at,

                                // ── FITUR BARU: Mengirim Data Semester Sesi Kelas ──
                                'semester' => $session->semester,

                                'lessons' => $session->materials->map(function ($material) {
                                    return [
                                        'id' => $material->id,
                                        'title' => $material->title,
                                        'type' => $material->type,
                                        'duration' => '15 mnt',
                                        'description' => $material->description,
                                        'content_url' => $material->content_url,
                                        'attachment_path' => $material->attachment_path,
                                        'quiz_id' => $material->quiz_id,
                                    ];
                                })->values()->toArray()
                            ];
                        })->values()->toArray()
                    ];
                });

            // Kalkulasi akumulasi total modul dan progres keseluruhan untuk Mata Pelajaran ini
            $totalModules = $modulesList->count();
            $totalCompletedModules = $modulesList->filter(function($mod) {
                return $mod['lessons_count'] > 0 && $mod['lessons_count'] == $mod['completed_count'];
            })->count();

            $progress = $totalModules > 0 ? round($totalCompletedModules / $totalModules, 2) : 0;

            return [
                'id' => $subject->id,
                'category' => strtoupper($subject->code ?? 'UMUM'),
                'title' => $subject->name,
                'description' => $subject->description ?? 'Deskripsi mata pelajaran belum tersedia.',
                'grade' => 'Kelas XI',
                'completed' => $totalCompletedModules,
                'total' => $totalModules,
                'progress' => $progress,
                'modules_list' => $modulesList->values()->toArray() // Dikonsumsi oleh Bottom Sheet & Detail Screen
            ];
        });

        // Filter agar mata pelajaran yang belum dikonfigurasi modulnya oleh guru tidak tampil di siswa
        $filteredSubjects = $subjects->filter(fn($s) => $s['total'] > 0)->values();

        return response()->json([
            'status' => 'success',
            'data' => $filteredSubjects
        ], 200);
    }
}
