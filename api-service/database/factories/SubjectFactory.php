<?php

namespace Database\Factories;

use App\Models\Subject;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

class SubjectFactory extends Factory
{
    protected $model = Subject::class;

    public function definition(): array
    {
        return [
            // Membuat kode unik (contoh: PWPB, PBO, MAT)
            'code' => fake()->unique()->bothify('???'),
            'name' => fake()->randomElement([
                'Pemrograman Web & Perangkat Bergerak',
                'Pemrograman Berorientasi Objek',
                'Basis Data',
                'Administrasi Sistem Jaringan',
                'Desain Grafis Percetakan',
                'Informatika Dasar'
            ]),
            'grade_level' => fake()->randomElement(['Kelas X', 'Kelas XI', 'Kelas XII']),

            // Mengambil departemen acak jika tidak didefinisikan secara spesifik
            'department_id' => Department::inRandomOrder()->first()?->id ?? Department::factory(),
        ];
    }

    /**
     * State untuk memaksa mata pelajaran masuk ke jurusan tertentu
     */
    public function forDepartment(int $departmentId): static
    {
        return $this->state(fn (array $attributes) => [
            'department_id' => $departmentId,
        ]);
    }
}
