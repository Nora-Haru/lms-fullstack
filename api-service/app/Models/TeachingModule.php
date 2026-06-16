<?php

// app/Models/TeachingModule.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TeachingModule extends Model
{
    protected $fillable = [
        'subject_id',
        'teacher_id',
        'title',
        'general_information',
        'core_components',
        'attachments',
    ];

    protected $casts = [
        // Menginstruksikan Eloquent untuk mem-parsing JSON menjadi Array asosiatif PHP
        'general_information' => 'array',
        'core_components' => 'array',
        'attachments' => 'array',
    ];

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }
}
