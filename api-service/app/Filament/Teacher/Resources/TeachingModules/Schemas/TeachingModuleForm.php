<?php

namespace App\Filament\Teacher\Resources\TeachingModules\Schemas;

use Filament\Schemas\Schema;
use Filament\Schemas\Components\Fieldset;
use Filament\Schemas\Components\Section; // 👈 Menambahkan import Section
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\Textarea; // 👈 Menambahkan import Textarea
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\FileUpload;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class TeachingModuleForm
{
    public static function configure(Schema $schema): Schema
    {
        $userId = Auth::id();
        $teacherId = \App\Models\Teacher::where('user_id', $userId)->value('id');

        return $schema
            ->components([
                Hidden::make('teacher_id')
                    ->default($teacherId),

                Fieldset::make('Informasi Utama')
                    ->schema([
                        Select::make('subject_id')
                            ->label('Mata Pelajaran')
                            ->relationship(
                                name: 'subject',
                                titleAttribute: 'name',
                                modifyQueryUsing: fn (Builder $query) => $query->whereHas('teachers', function ($q) use ($teacherId) {
                                    $q->where('teacher_id', $teacherId)
                                      ->where('is_verified', true);
                                })
                            )
                            ->required()
                            ->searchable()
                            ->preload()
                            ->columnSpan(1),

                        TextInput::make('title')
                            ->label('Judul Modul')
                            ->placeholder('Contoh: Memahami Arsitektur MVC pada Laravel')
                            ->required()
                            ->maxLength(255)
                            ->columnSpan(1),
                    ])->columns(2),

                Fieldset::make('Informasi Umum (General Information)')
                    ->schema([
                        // ── UBAH BAGIAN INI MENJADI SELECT ──
                        Select::make('general_information.semester')
                            ->label('Semester')
                            ->options([
                                'Ganjil' => 'Ganjil',
                                'Genap' => 'Genap',
                            ])
                            ->required(),

                        TextInput::make('general_information.target_audience')
                            ->label('Fase / Kelas Sasaran')
                            ->placeholder('Contoh: Siswa Kelas XI TKJ')
                            ->required(),

                        TextInput::make('general_information.learning_approach')
                            ->label('Pendekatan Pembelajaran')
                            ->placeholder('Contoh: Project-based Learning (PjBL)')
                            ->required(),

                        TagsInput::make('general_information.theories')
                            ->label('Teori Belajar yang Diterapkan')
                            ->placeholder('Ketik lalu tekan Enter (Contoh: Behavioristik)'),
                    ])->columns(2),

                // ── TAMBAHAN BARU: Section Karakteristik & Detail Modul ──
                Section::make('Karakteristik & Detail Modul')
                    ->description('Isi pengantar, capaian, dan tujuan. Gunakan tombol Enter (baris baru) untuk memisahkan setiap poin.')
                    ->collapsible()
                    ->schema([
                        Textarea::make('introduction')
                            ->label('Pengantar Modul')
                            ->placeholder('Contoh: Modul ini fokus pada praktik singkat agar konsep cepat melekat.')
                            ->rows(3)
                            ->required()
                            ->columnSpanFull(),

                        Textarea::make('learning_achievements')
                            ->label('Capaian Pembelajaran (Pisahkan dengan Enter)')
                            ->placeholder("Contoh:\nPeserta didik mampu memodelkan masalah dunia nyata.\nPeserta didik mampu menerapkan prinsip enkapsulasi.\n")
                            ->rows(4)
                            ->required()
                            ->columnSpanFull(),

                        Textarea::make('learning_objectives')
                            ->label('Tujuan Pembelajaran (Pisahkan dengan Enter)')
                            ->placeholder("Contoh:\nMendefinisikan kelas, atribut, dan method.\nMenggunakan modifier akses.\n")
                            ->rows(4)
                            ->required()
                            ->columnSpanFull(),
                    ]),
                // ──────────────────────────────────────────────────────────

                Fieldset::make('Komponen Inti (Core Components)')
                    ->schema([
                        Repeater::make('core_components')
                            ->label('Daftar Bab/Materi')
                            ->schema([
                                TextInput::make('chapter')
                                    ->label('Bab / Sesi')
                                    ->placeholder('Contoh: Bab 1')
                                    ->required()
                                    ->columnSpan(1),

                                TextInput::make('title')
                                    ->label('Judul Materi')
                                    ->placeholder('Contoh: Konsep Dasar MVC')
                                    ->required()
                                    ->columnSpan(2),

                                RichEditor::make('description')
                                    ->label('Deskripsi / Isi Materi')
                                    ->required()
                                    ->columnSpanFull(),
                            ])
                            ->columns(3)
                            ->columnSpanFull(),
                    ])->columns(1),

                Fieldset::make('Lampiran (Attachments)')
                    ->schema([
                        TextInput::make('attachments.assessment_type')
                            ->label('Tipe Asesmen')
                            ->placeholder('Contoh: Uraian & Proyek Interaktif'),

                        FileUpload::make('attachments.files')
                            ->label('Unggah File Lampiran (LKPD / Modul PDF)')
                            ->multiple()
                            ->directory('teaching-modules/attachments')
                            ->acceptedFileTypes(['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
                            ->maxSize(5120),
                    ])->columns(1),
            ]);
    }
}
