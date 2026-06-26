<?php

namespace Database\Factories;

use App\Models\Student;
use App\Models\User;
use App\Models\Classroom;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(), // Membuat user baru secara otomatis
            'nisn' => fake()->unique()->numerify('##########'),
            'nis' => fake()->unique()->numerify('#####'),
            'enrollment_year' => fake()->numberBetween(2024, 2026),

            // Default: ambil acak jika tidak didefinisikan
            'department_id' => Department::inRandomOrder()->first()?->id ?? Department::factory(),
            'classroom_id' => Classroom::inRandomOrder()->first()?->id ?? Classroom::factory(),
        ];
    }

    /**
     * State untuk menempatkan siswa di kelas & jurusan tertentu secara konsisten
     */
    public function forClassroom(int $departmentId, int $classroomId): static
    {
        return $this->state(fn (array $attributes) => [
            'department_id' => $departmentId,
            'classroom_id' => $classroomId,
        ]);
    }
}
