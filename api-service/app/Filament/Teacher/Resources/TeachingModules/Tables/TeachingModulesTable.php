<?php

namespace App\Filament\Teacher\Resources\TeachingModules\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class TeachingModulesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('subject.code')
                    ->label('Kode')
                    ->sortable()
                    ->searchable()
                    ->badge()
                    ->color('gray'),

                TextColumn::make('subject.name')
                    ->label('Mata Pelajaran')
                    ->sortable()
                    ->searchable()
                    ->wrap(),

                // Menampilkan nama jurusan, jika bernilai NULL maka fallback ke string 'Umum / Nasional'
                TextColumn::make('subject.department.name')
                    ->label('Jurusan')
                    ->sortable()
                    ->searchable()
                    ->default('Umum / Nasional'),

                TextColumn::make('subject.grade_level')
                    ->label('Kelas')
                    ->sortable()
                    ->searchable(),

                // Parsing JSON dinamis menggunakan operator ->
                TextColumn::make('general_information->semester')
                    ->label('Semester')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('title')
                    ->label('Judul Modul')
                    ->searchable()
                    ->wrap(),

                TextColumn::make('created_at')
                    ->label('Dibuat Pada')
                    ->dateTime('d M Y, H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
