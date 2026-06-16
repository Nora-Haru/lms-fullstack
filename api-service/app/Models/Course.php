<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'department_name',
        'grade_level',
        'total_lessons',
        'completed_lessons',
        'thumbnail_url',
    ];

    protected $casts = [
        'total_lessons' => 'integer',
        'completed_lessons' => 'integer',
    ];
}
