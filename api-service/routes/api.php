<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
//use App\Http\Controllers\Api\CourseController;
use App\Http\Controllers\Api\StudentDashboardController;

//Route::get('/courses', [CourseController::class, 'index']);

// Rute Publik (Tidak butuh token)
Route::post('/login', [AuthController::class, 'login']);

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

Route::middleware('auth:sanctum')->group(function () {

    // Cek profil user yang sedang login
    Route::get('/user', function (Request $request) {
        $user = $request->user()->load(['teacher', 'student.classroom']);
        return response()->json(['data' => $user]);
    });
    Route::get('/student/modules', [StudentDashboardController::class, 'index']);
    // Rute Logout
    Route::post('/logout', [AuthController::class, 'logout']);

});
