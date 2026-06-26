<?php

namespace Database\Factories;

use App\Models\Teacher;
use App\Models\User;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

class TeacherFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(), // Otomatis membuat User saat Teacher dibuat
            'nip' => fake()->numerify('19################'), // Format NIP 18 digit
            'employment_status' => fake()->randomElement(['PNS', 'PPPK', 'Honorir']),
            'ptk_type' => 'Guru Mata Pelajaran',
            'department_id' => Department::inRandomOrder()->first()?->id ?? Department::factory(),
        ];
    }

    /**
     * State untuk menentukan departemen guru secara spesifik
     */
    public function forDepartment(int $departmentId): static
    {
        return $this->state(fn (array $attributes) => [
            'department_id' => $departmentId,
        ]);
    }
}
