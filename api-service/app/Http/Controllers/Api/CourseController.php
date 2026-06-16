<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
use App\Models\Course;
use Illuminate\Http\JsonResponse;

class CourseController extends Controller
{
    public function index(): JsonResponse
    {
        $courses = Course::latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Data modul pembelajaran berhasil diambil.',
            'data' => $courses
        ]);
    }
}
