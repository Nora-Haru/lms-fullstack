<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
// use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Laravel\Sanctum\HasApiTokens;
use Filament\Models\Contracts\FilamentUser; // Import Interface
use Filament\Panel;
// use Spatie\Permission\Traits\HasRoles;

#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory <UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;//, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'password',
        'is_active',
        'last_login_at',
        'last_login_ip',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_active' => 'boolean',
        'last_login_at' => 'datetime',
    ];

    // Relasi One-to-One (Delegation Pattern)
    public function teacher(): HasOne
    {
        return $this->hasOne(Teacher::class);
    }

    public function student(): HasOne
    {
        return $this->hasOne(Student::class);
    }

    // Metode Wajib untuk Otorisasi Panel Filament
    public function canAccessPanel(Panel $panel): bool
    {
        // Blokir akses jika akun dinonaktifkan
        if (!$this->is_active) {
            return false;
        }

        if ($panel->getId() === 'lmsAdmin') {
            // Otorisasi sementara menggunakan email sebelum integrasi Spatie RBAC
            return $this->email === 'admin@lms.local';
        }

        if ($panel->getId() === 'teacher') {
            // Otorisasi melalui validasi relasi One-to-One dengan tabel teachers
            return $this->teacher()->exists();
        }

        return false;
    }
}
