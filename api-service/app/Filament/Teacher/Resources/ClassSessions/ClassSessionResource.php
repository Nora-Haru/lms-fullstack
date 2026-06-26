<?php

namespace App\Filament\Teacher\Resources\ClassSessions;

use App\Filament\Teacher\Resources\ClassSessions\Pages\CreateClassSession;
use App\Filament\Teacher\Resources\ClassSessions\Pages\EditClassSession;
use App\Filament\Teacher\Resources\ClassSessions\Pages\ListClassSessions;
use App\Filament\Teacher\Resources\ClassSessions\RelationManagers\AttendancesRelationManager;

use App\Models\ClassSession;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

use Filament\Schemas\Components\Fieldset;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\FileUpload; // Impor komponen untuk unggah dokumen/tugas
use Filament\Schemas\Components\Section;

use Filament\Tables\Columns\TextColumn;

use Filament\Actions\EditAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

// use Flament\Forms\Components\Set; outdated di filament 5
// use Filament\Schemas\Components\Utilities\Set;

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
                                modifyQueryUsing: fn (Builder $query, $get) => $query
                                    ->where('teacher_id', $teacherId)
                                    ->when($get('subject_id'), fn ($q, $subjectId) => $q->where('subject_id', $subjectId))
                            )
                            ->searchable()
                            ->preload()
                            ->placeholder('Pilih modul jika ada')
                            // ── PENAMBAHAN FITUR AUTO-FILL SEMESTER ──
                           ->live()
                            ->afterStateUpdated(function ($state, callable $set) {
                                if ($state) {
                                    $module = \App\Models\TeachingModule::find($state);

                                    if ($module && isset($module->general_information['semester'])) {
                                        // ── PERBAIKAN DI SINI: Gunakan strtolower() ──
                                        $nilaiSemester = strtolower($module->general_information['semester']);
                                        $set('semester', $nilaiSemester);
                                    }
                                }
                            }),
                    ])->columns(3),

                Fieldset::make('Parameter Pertemuan & Pelaksanaan')
                    ->schema([
                        TextInput::make('academic_year_start')
                            ->label('Tahun Ajaran')
                            ->numeric()
                            ->default(date('Y'))
                            ->required()
                            ->columnSpan(1),

                        Select::make('semester')
                            ->label('Semester')
                            ->options([
                                'ganjil' => 'Ganjil',
                                'genap' => 'Genap',
                            ])
                            ->required()
                            ->columnSpan(1),

                        TextInput::make('meeting_number')
                            ->label('Pertemuan Ke-')
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(32)
                            ->required()
                            ->columnSpan(1),

                        TextInput::make('title')
                            ->label('Topik / Agenda Pertemuan')
                            ->required()
                            ->maxLength(255)
                            ->columnSpan(3),

                        Select::make('type')
                            ->label('Jenis Sesi')
                            ->options([
                                'regular' => 'Tatap Muka Reguler',
                                'uts' => 'Ujian Tengah Semester (UTS)',
                                'uas' => 'Ujian Akhir Semester (UAS)',
                                'remedial' => 'Remedial',
                            ])
                            ->default('regular')
                            ->required()
                            ->columnSpan(2),

                        Select::make('method')
                            ->label('Metode')
                            ->options([
                                'offline' => 'Luring (Offline)',
                                'online' => 'Daring (Online)',
                                'hybrid' => 'Hybrid',
                            ])
                            ->default('offline')
                            ->required()
                            ->columnSpan(2),

                        DateTimePicker::make('scheduled_at')
                            ->label('Jadwal Pelaksanaan')
                            ->required()
                            ->columnSpan(2),

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
                            ->required()
                            ->columnSpan(2),
                    ])->columns(6),

                // ── REFAKTOR: Form Komponen Konten & Materi Pertemuan Dinamis ──
                Section::make('Konten & Materi Pertemuan')
                    ->description('Tambahkan aktivitas pembelajaran. Form input akan menyesuaikan secara dinamis berdasarkan tipe konten yang Anda pilih.')
                    ->collapsible()
                    ->schema([
                        Repeater::make('materials')
                            ->relationship()
                            ->label('Daftar Materi & Aktivitas')
                            ->addActionLabel('Tambah Materi / Aktivitas Baru')
                            ->schema([
                                TextInput::make('title')
                                    ->label('Judul Materi / Aktivitas')
                                    ->placeholder('Contoh: Pertemuan 1: Pengenalan Arsitektur MVC')
                                    ->required()
                                    ->columnSpan(2),

                                Select::make('type')
                                    ->label('Tipe Konten / Aktivitas')
                                    ->options([
                                        'video' => '🎬 Video / Link YouTube',
                                        'document' => '📄 Dokumen (PDF, Word, PPT)',
                                        'quiz' => '🏆 Kuis / Ujian LMS',
                                        'task' => '📝 Tugas Mandiri Siswa',
                                    ])
                                    ->required()
                                    ->live() // Mengaktifkan mode reaktif instan
                                    ->columnSpan(1),

                                Textarea::make('description')
                                    ->label('Isi Materi / Deskripsi Instruksi')
                                    ->placeholder('Ketik isi materi rangkuman teks, deskripsi penjelas, atau rincian instruksi tugas di sini secara manual...')
                                    ->rows(3)
                                    ->columnSpanFull(),

                                // Muncul KHUSUS jika memilih video
                                TextInput::make('content_url')
                                    ->label('Tautan Video Pembelajaran (YouTube / Google Drive)')
                                    ->placeholder('https://www.youtube.com/watch?v=xxxxxx')
                                    ->url()
                                    ->visible(fn ($get) => $get('type') === 'video')
                                    ->required(fn ($get) => $get('type') === 'video')
                                    ->columnSpanFull(),

                                // Muncul jika memilih Dokumen atau Tugas (Untuk mengunggah lampiran soal/file bacaan)
                                FileUpload::make('attachment_path')
                                    ->label('Unggah File Lampiran (Modul PDF / Soal Tugas)')
                                    ->directory('class-session-attachments')
                                    ->preserveFilenames()
                                    ->visible(fn ($get) => in_array($get('type'), ['document', 'task']))
                                    ->columnSpanFull(),

                                // Muncul KHUSUS jika memilih Kuis (Menghubungkan ke menu kuis mandiri nanti)
                                Select::make('quiz_id')
                                    ->label('Hubungkan dengan Paket Kuis / Ujian')
                                    ->placeholder('Pilih kuis yang telah Anda buat di menu Bank Kuis')
                                    ->options([
                                        '1' => 'Kuis Pertemuan 1: Dasar Pemetaan Routing Laravel',
                                        '2' => 'Ulangan Harian 1: Implementasi Controller & View',
                                    ])
                                    ->visible(fn ($get) => $get('type') === 'quiz')
                                    ->required(fn ($get) => $get('type') === 'quiz')
                                    ->columnSpanFull(),
                            ])
                            ->columns(3)
                            ->itemLabel(fn (array $state): ?string => $state['title'] ?? 'Aktivitas Baru')
                            ->reorderableWithButtons(),
                    ]),

                Section::make('Jurnal & Evaluasi')
                    ->collapsed()
                    ->schema([
                        Textarea::make('teacher_notes')
                            ->label('Jurnal / Catatan Guru')
                            ->placeholder('Tulis evaluasi atau catatan khusus setelah kelas selesai...')
                            ->rows(4)
                            ->columnSpanFull(),
                    ]),
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
