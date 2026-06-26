<?php

// app/Models/Department.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Department extends Model
{
    use HasFactory; // 2. Tambahkan trait ini di dalam class

    protected $fillable = ['code', 'name'];

    public function classrooms(): HasMany
    {
        return $this->hasMany(Classroom::class);
    }

    public function teachers(): HasMany
    {
        return $this->hasMany(Teacher::class);
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }
}
