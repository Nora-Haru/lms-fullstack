<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('class_session_materials', function (Blueprint $table) {
            $table->id();
            // Menghubungkan materi ke Sesi Kelas / Pertemuan tertentu
            $table->foreignId('class_session_id')->constrained('class_sessions')->onDelete('cascade');
            $table->string('title');
            // Menentukan tipe konten sesuai kebutuhan UI di Flutter
            $table->enum('type', ['video', 'document', 'quiz', 'task'])->default('document');
            $table->string('content_url')->nullable(); // Tautan video/dokumen/kuis
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('class_session_materials');
    }
};
