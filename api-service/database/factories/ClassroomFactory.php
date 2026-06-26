<?php

namespace Database\Factories;

use App\Models\Classroom;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClassroomFactory extends Factory
{
    protected $model = Classroom::class;

    public function definition(): array
    {
        // Pastikan ada departemen, jika tidak ada, buat satu
        $department = Department::inRandomOrder()->first() ?? Department::factory()->create();

        $grade = fake()->randomElement(['Kelas X', 'Kelas XI', 'Kelas XII']);

        return [
            'department_id' => $department->id,
            'grade_level' => $grade,
            // Membuat nama kelas dinamis: "XI RPL 1"
            'name' => $grade . ' ' . $department->code . ' ' . fake()->numberBetween(1, 3),
        ];
    }

    /**
     * State untuk menentukan kelas pada departemen tertentu
     */
    public function forDepartment(int $departmentId): static
    {
        return $this->state(fn (array $attributes) => [
            'department_id' => $departmentId,
        ]);
    }
}
