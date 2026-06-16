<?php

namespace App\Filament\Teacher\Resources\ClassSessions;

// Impor Eksplisit untuk Halaman (Pages)
use App\Filament\Teacher\Resources\ClassSessions\Pages\CreateClassSession;
use App\Filament\Teacher\Resources\ClassSessions\Pages\EditClassSession;
use App\Filament\Teacher\Resources\ClassSessions\Pages\ListClassSessions;

// Impor Relation Manager
use App\Filament\Teacher\Resources\ClassSessions\RelationManagers\AttendancesRelationManager;

use App\Models\ClassSession;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

// 1. PERBAIKAN: Namespace Form Components (Kembali menggunakan Forms\Components)
use Filament\Schemas\Components\Fieldset;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Textarea;
// use Filament\Forms\Get;

// 2. PERBAIKAN: Namespace Table Columns
use Filament\Tables\Columns\TextColumn;

// 3. PERBAIKAN: Namespace Actions (Berpindah ke Filament\Actions global)
use Filament\Actions\EditAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

class ClassSessionResource extends Resource
{
    protected static ?string $model = ClassSession::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-calendar-days';

    protected static ?string $navigationLabel = 'Sesi Kelas (Jadwal)';
    protected static ?string $modelLabel = 'Sesi Kelas';
    protected static ?string $pluralModelLabel = 'Sesi Kelas';

    public static function getEloquentQuery(): Builder
    {
        $userId = Auth::id();
        $teacherId = \App\Models\Teacher::where('user_id', $userId)->value('id');

        return parent::getEloquentQuery()->where('teacher_id', $teacherId);
    }

    public static function form(Schema $schema): Schema
    {
        $userId = Auth::id();
        $teacherId = \App\Models\Teacher::where('user_id', $userId)->value('id');

        return $schema
            ->components([
                Hidden::make('teacher_id')
                    ->default($teacherId),

                Fieldset::make('Konteks Akademik')
                    ->schema([
                        Select::make('subject_id')
                            ->label('Mata Pelajaran')
                            ->relationship(
                                name: 'subject',
                                titleAttribute: 'name',
                                modifyQueryUsing: fn (Builder $query) => $query->whereHas('teachers', function ($q) use ($teacherId) {
                                    $q->where('teacher_id', $teacherId)->where('is_verified', true);
                                })
                            )
                            ->required()
                            ->searchable()
                            ->preload()
                            ->live(),

                        Select::make('classroom_id')
                            ->label('Rombongan Belajar (Rombel)')
                            ->relationship('classroom', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),

                        Select::make('teaching_module_id')
                            ->label('Cetak Biru Modul Ajar (Opsional)')
                            ->relationship(
                                name: 'teachingModule',
                                titleAttribute: 'title',
                                // PERBAIKAN: Hapus kata "Get" sebelum variabel $get
                                modifyQueryUsing: fn (Builder $query, $get) => $query
                                    ->where('teacher_id', $teacherId)
                                    ->when($get('subject_id'), fn ($q, $subjectId) => $q->where('subject_id', $subjectId))
                            )
                            ->searchable()
                            ->preload()
                            ->placeholder('Pilih modul jika ada'),
                    ])->columns(3),

                Fieldset::make('Parameter Pertemuan')
                    ->schema([
                        TextInput::make('academic_year_start')
                            ->label('Tahun Ajaran (Awal)')
                            ->numeric()
                            ->default(date('Y'))
                            ->required(),

                        Select::make('semester')
                            ->label('Semester')
                            ->options([
                                'ganjil' => 'Ganjil',
                                'genap' => 'Genap',
                            ])
                            ->required(),

                        TextInput::make('meeting_number')
                            ->label('Pertemuan Ke-')
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(32)
                            ->required(),

                        TextInput::make('title')
                            ->label('Topik / Agenda Pertemuan')
                            ->required()
                            ->maxLength(255)
                            ->columnSpan(2),
                    ])->columns(5),

                Fieldset::make('Pelaksanaan & Status')
                    ->schema([
                        Select::make('type')
                            ->label('Jenis Sesi')
                            ->options([
                                'regular' => 'Tatap Muka Reguler',
                                'uts' => 'Ujian Tengah Semester (UTS)',
                                'uas' => 'Ujian Akhir Semester (UAS)',
                                'remedial' => 'Remedial',
                            ])
                            ->default('regular')
                            ->required(),

                        Select::make('method')
                            ->label('Metode')
                            ->options([
                                'offline' => 'Luring (Offline)',
                                'online' => 'Daring (Online)',
                                'hybrid' => 'Hybrid',
                            ])
                            ->default('offline')
                            ->required(),

                        DateTimePicker::make('scheduled_at')
                            ->label('Jadwal Pelaksanaan')
                            ->required(),

                        Select::make('status')
                            ->label('Status Sesi')
                            ->options([
                                'draft' => 'Draft',
                                'scheduled' => 'Terjadwal',
                                'ongoing' => 'Sedang Berlangsung',
                                'completed' => 'Selesai',
                                'canceled' => 'Dibatalkan',
                            ])
                            ->default('draft')
                            ->required(),

                        Textarea::make('teacher_notes')
                            ->label('Jurnal / Catatan Guru')
                            ->placeholder('Tulis evaluasi atau catatan khusus setelah kelas selesai...')
                            ->columnSpanFull(),
                    ])->columns(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('scheduled_at')
                    ->label('Jadwal')
                    ->dateTime('d M Y, H:i')
                    ->sortable(),

                TextColumn::make('classroom.name')
                    ->label('Rombel')
                    ->sortable()
                    ->searchable()
                    ->badge()
                    ->color('info'),

                TextColumn::make('subject.code')
                    ->label('Mapel')
                    ->sortable()
                    ->searchable(),

                TextColumn::make('meeting_number')
                    ->label('Ke-')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('title')
                    ->label('Topik')
                    ->searchable()
                    ->wrap(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    // 4. PERBAIKAN: Pembaruan API styling warna badge menggunakan match statement
                    ->color(fn (string $state): string => match ($state) {
                        'draft' => 'gray',
                        'scheduled' => 'warning',
                        'ongoing' => 'info',
                        'completed' => 'success',
                        'canceled' => 'danger',
                        default => 'primary',
                    }),
            ])
            ->filters([
                //
            ])
            ->actions([
                EditAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('scheduled_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            AttendancesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListClassSessions::route('/'),
            'create' => CreateClassSession::route('/create'),
            'edit' => EditClassSession::route('/{record}/edit'),
        ];
    }
}
