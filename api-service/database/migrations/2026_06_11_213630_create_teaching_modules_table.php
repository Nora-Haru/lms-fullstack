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
        Schema::create('teaching_modules', function (Blueprint $table) {
            $table->id();

            // Relasi ke Mata Pelajaran dan Guru Pembuat Modul
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('teacher_id')->constrained()->cascadeOnDelete();

            $table->string('title'); // ex: Memahami Arsitektur MVC pada Laravel

            // Kolom JSON untuk segmentasi pedagogis
            $table->json('general_information');
            $table->json('core_components');
            $table->json('attachments')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teaching_modules');
    }
};
