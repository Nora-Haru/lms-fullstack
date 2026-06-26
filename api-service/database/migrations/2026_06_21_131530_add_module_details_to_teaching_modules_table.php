<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('teaching_modules', function (Blueprint $table) {
            // Ganti 'module_title' menjadi 'title'
            $table->text('learning_achievements')->nullable()->after('title');
            $table->text('learning_objectives')->nullable()->after('learning_achievements');
            $table->text('introduction')->nullable()->after('learning_objectives');
        });
    }

    public function down(): void
    {
        Schema::table('teaching_modules', function (Blueprint $table) {
            $table->dropColumn(['learning_achievements', 'learning_objectives', 'introduction']);
        });
    }
};
