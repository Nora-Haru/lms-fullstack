<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Subject extends Model
{
    /** @use HasFactory<\Database\Factories\SubjectFactory> */
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'grade_level',
        'departement_id',
    ];

    // Relasi ke tabel Departments (Jurusan)
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    // Relasi Many-to-Many dengan Teachers
    public function teachers(): BelongsToMany
    {
        return $this->belongsToMany(Teacher::class)
                    ->withPivot(['is_verified', 'verified_by'])
                    ->withTimestamps();
    }
}
