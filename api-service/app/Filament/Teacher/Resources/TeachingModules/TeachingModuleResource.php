<?php

namespace App\Filament\Teacher\Resources\TeachingModules;

use App\Filament\Teacher\Resources\TeachingModules\Pages\CreateTeachingModule;
use App\Filament\Teacher\Resources\TeachingModules\Pages\EditTeachingModule;
use App\Filament\Teacher\Resources\TeachingModules\Pages\ListTeachingModules;
use App\Filament\Teacher\Resources\TeachingModules\Schemas\TeachingModuleForm;
use App\Filament\Teacher\Resources\TeachingModules\Tables\TeachingModulesTable;
use App\Models\TeachingModule;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth; // Injeksi Facade Auth

class TeachingModuleResource extends Resource
{
    protected static ?string $model = TeachingModule::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedDocumentText;

    protected static ?string $recordTitleAttribute = 'title';

    protected static ?string $modelLabel = 'Modul Pembelajaran';

    protected static ?string $pluralModelLabel = 'Modul Pembelajaran';

    public static function getEloquentQuery(): Builder
    {
        // Resolusi Type-Safe menggunakan Facade Auth untuk mencegah Intelephense Error
        $userId = Auth::id();
        $teacherId = \App\Models\Teacher::where('user_id', $userId)->value('id');

        return parent::getEloquentQuery()->where('teacher_id', $teacherId);
    }

    public static function form(Schema $schema): Schema
    {
        return TeachingModuleForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return TeachingModulesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTeachingModules::route('/'),
            'create' => CreateTeachingModule::route('/create'),
            'edit' => EditTeachingModule::route('/{record}/edit'),
        ];
    }
}
