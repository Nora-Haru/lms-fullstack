<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClassSessionMaterial extends Model
{
    // Mengizinkan semua kolom ini untuk disimpan oleh form Filament
    protected $fillable = [
        'class_session_id',
        'title',
        'type',
        'content_url',
        'description',      // Kolom baru
        'attachment_path',  // Kolom baru
        'quiz_id'           // Kolom baru
    ];

    public function classSession(): BelongsTo
    {
        return $this->belongsTo(ClassSession::class);
    }
}
