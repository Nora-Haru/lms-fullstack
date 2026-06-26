<?php

namespace Database\Factories;

use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

class DepartmentFactory extends Factory
{
    protected $model = Department::class;

    public function definition(): array
    {
        // Daftar departemen SMK standar
        $departments = [
            ['name' => 'Rekayasa Perangkat Lunak', 'code' => 'RPL'],
            ['name' => 'Teknik Komputer & Jaringan', 'code' => 'TKJ'],
            ['name' => 'Desain Komunikasi Visual', 'code' => 'DKV'],
            ['name' => 'Akuntansi', 'code' => 'AKL'],
            ['name' => 'Bisnis Daring dan Pemasaran', 'code' => 'BDP'],
        ];

        $dept = fake()->unique()->randomElement($departments);

        return [
            'name' => $dept['name'],
            'code' => $dept['code'],
        ];
    }
}
