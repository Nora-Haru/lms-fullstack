<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_session_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();

            // State tracking presensi
            $table->enum('status', ['present', 'sick', 'permission', 'absent', 'late', 'unmarked'])->default('unmarked');

            // Timestamp pencatatan presensi real-time (untuk integrasi Flutter GPS/Barcode nantinya)
            $table->datetime('time_in')->nullable();
            $table->string('notes')->nullable();

            $table->timestamps();

            // Indeks Komposit: Satu siswa hanya dapat memiliki satu record presensi per satu sesi kelas
            $table->unique(['class_session_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
