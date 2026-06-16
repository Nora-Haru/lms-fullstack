<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('class_sessions', function (Blueprint $table) {
            $table->id();

            // Relasi Kontekstual
            $table->foreignId('teacher_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('classroom_id')->constrained()->cascadeOnDelete(); // Target Rombel (e.g., XI TKJ 1)
            $table->foreignId('teaching_module_id')->nullable()->constrained()->nullOnDelete(); // Cetak Biru Materi

            // Parameter Waktu & Siklus Akademik
            $table->tinyInteger('academic_year_start'); // e.g., 2026
            $table->enum('semester', ['ganjil', 'genap']);
            $table->tinyInteger('meeting_number'); // 1 - 16

            // Meta Pertemuan
            $table->string('title');
            $table->enum('type', ['regular', 'uts', 'uas', 'remedial'])->default('regular');
            $table->enum('method', ['offline', 'online', 'hybrid'])->default('offline');
            $table->datetime('scheduled_at')->nullable();

            // Status & Catatan
            $table->enum('status', ['draft', 'scheduled', 'ongoing', 'completed', 'canceled'])->default('draft');
            $table->text('teacher_notes')->nullable(); // Jurnal mengajar

            $table->timestamps();

            // Indeks Komposit untuk mencegah duplikasi jadwal (Satu guru tidak bisa mengajar 2 kelas di waktu yang sama)
            $table->unique(['teacher_id', 'scheduled_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('class_sessions');
    }
};
