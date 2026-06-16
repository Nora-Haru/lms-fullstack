<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ClassSession extends Model
{
    protected $fillable = [
        'teacher_id', 'subject_id', 'classroom_id', 'teaching_module_id',
        'academic_year_start', 'semester', 'meeting_number', 'title',
        'type', 'method', 'scheduled_at', 'status', 'teacher_notes',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'meeting_number' => 'integer',
        'academic_year_start' => 'integer',
    ];

    public function teacher(): BelongsTo { return $this->belongsTo(Teacher::class); }
    public function subject(): BelongsTo { return $this->belongsTo(Subject::class); }
    public function classroom(): BelongsTo { return $this->belongsTo(Classroom::class); }
    public function teachingModule(): BelongsTo { return $this->belongsTo(TeachingModule::class); }

    // Relasi One-to-Many ke tabel turunan
    public function attendances(): HasMany
    {
        return $this->hasMany(Attendance::class);
    }

    // Automasi Generasi Record Presensi menggunakan Eloquent Model Events
    protected static function booted(): void
    {
        static::created(function (ClassSession $session) {
            // Ekstraksi ID seluruh siswa yang terdaftar di Rombel terkait
            $studentIds = Student::where('classroom_id', $session->classroom_id)->pluck('id');

            if ($studentIds->isEmpty()) {
                return;
            }

            // Konstruksi array multidimensi untuk Bulk Insert (O(1) Query Time)
            $attendances = $studentIds->map(fn($studentId) => [
                'class_session_id' => $session->id,
                'student_id'       => $studentId,
                'status'           => 'unmarked',
                'created_at'       => now(),
                'updated_at'       => now(),
            ])->toArray();

            // Eksekusi injeksi data secara massal tanpa membebani memori dengan iterasi Eloquent
            Attendance::insert($attendances);
        });
    }
}
