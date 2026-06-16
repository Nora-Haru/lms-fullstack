<?php

namespace Database\Factories;

use App\Models\Course;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Course>
 */
// database/factories/CourseFactory.php
namespace Database\Factories;

use App\Models\Course;
use Illuminate\Database\Eloquent\Factories\Factory;

class CourseFactory extends Factory
{
    protected $model = Course::class;

    public function definition(): array
    {
        $totalLessons = fake()->numberBetween(6, 25);
        $completedLessons = fake()->numberBetween(0, $totalLessons);

        return [
            'title' => fake()->randomElement([
                'Administrasi Infrastruktur Jaringan',
                'Pemrograman Berorientasi Objek',
                'Desain Grafis Percetakan',
                'Teknik Pengelasan SMAW',
                'Pemodelan Perangkat Lunak',
                'Sistem Operasi Jaringan',
                'Animasi 2D dan 3D',
            ]),
            'description' => 'Kompetensi inti meliputi ' . fake()->sentence(12),
            'department_name' => fake()->randomElement([
                'Teknik Komputer & Jaringan',
                'Rekayasa Perangkat Lunak',
                'Multimedia',
                'Teknik Mesin',
            ]),
            'grade_level' => fake()->randomElement(['Kelas X', 'Kelas XI', 'Kelas XII']),
            'total_lessons' => $totalLessons,
            'completed_lessons' => $completedLessons,
            'thumbnail_url' => 'https://picsum.photos/seed/' . fake()->uuid() . '/600/400',
        ];
    }
}
