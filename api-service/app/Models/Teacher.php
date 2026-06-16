<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Teacher extends Model
{
    /** @use HasFactory<\Database\Factories\TeacherFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id',
        'nip',
        'nuptk',
        'employment_status',
        'ptk_type',
        'start_date',
        'gender',
        'birth_place',
        'birth_date',
        'phone',
        'address',
        'avatar_url',
        'department_id',
        'classroom_id',
    ];

    protected $casts = [
        'start_date' => 'date',
        'birth_date' => 'date',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    // Wali Kelas
    public function classroom(): BelongsTo
    {
        return $this->belongsTo(Classroom::class);
    }

    // Relasi Many-to-Many dengan Subjects (Mata Pelajaran yang diampu)
    public function subjects(): BelongsToMany
    {
        return $this->belongsToMany(Subject::class)
                    ->withPivot(['is_verified', 'verified_by'])
                    ->withTimestamps();
    }
}
