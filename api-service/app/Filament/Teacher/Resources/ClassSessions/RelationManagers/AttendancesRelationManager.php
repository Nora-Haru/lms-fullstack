<?php

namespace App\Filament\Teacher\Resources\ClassSessions\RelationManagers;

// Namespace yang dirombak mengikuti Filament 5.x
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AttendancesRelationManager extends RelationManager
{
    protected static string $relationship = 'attendances';
    protected static ?string $title = 'Jurnal Presensi Siswa';

    // 1. FORM MODAL: Akan muncul ketika guru menekan tombol "Edit"
    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('status')
                    ->label('Status Kehadiran')
                    ->options([
                        'unmarked' => 'Belum Ditandai',
                        'present' => 'Hadir',
                        'sick' => 'Sakit',
                        'permission' => 'Izin',
                        'absent' => 'Alpa',
                        'late' => 'Terlambat',
                    ])
                    ->required()
                    ->native(false),

                TextInput::make('notes')
                    ->label('Catatan (Opsional)')
                    ->placeholder('Keterangan izin/sakit...')
                    ->maxLength(255),

                TimePicker::make('time_in')
                    ->label('Waktu Check-in'),
            ]);
    }

    // 2. GRID TABEL: Tampilan daftar siswa
    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('student.nis')
            ->columns([
                TextColumn::make('student.nis')
                    ->label('NIS')
                    ->searchable()
                    ->sortable()
                    ->copyable(),

                TextColumn::make('student.user.name')
                    ->label('Nama Siswa')
                    ->searchable()
                    ->sortable(),

                // Menggunakan TextColumn dengan Badge karena SelectColumn ditiadakan
                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'unmarked' => 'gray',
                        'present' => 'success',
                        'sick' => 'warning',
                        'permission' => 'info',
                        'absent' => 'danger',
                        'late' => 'danger',
                        default => 'primary',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'unmarked' => 'Belum Ditandai',
                        'present' => 'Hadir',
                        'sick' => 'Sakit',
                        'permission' => 'Izin',
                        'absent' => 'Alpa',
                        'late' => 'Terlambat',
                        default => $state,
                    }),

                TextColumn::make('notes')
                    ->label('Catatan')
                    ->limit(20)
                    ->tooltip(function (TextColumn $column): ?string {
                        $state = $column->getState();
                        return strlen((string) $state) > 20 ? $state : null;
                    }),

                TextColumn::make('time_in')
                    ->label('Waktu Masuk')
                    ->formatStateUsing(fn ($state) => $state ? \Carbon\Carbon::parse($state)->format('H:i') : 'Belum masuk')
                    ->badge()
                    ->color(fn ($state) => $state ? 'success' : 'gray'),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                // Sengaja dikosongkan (CreateAction dihapus) karena data siswa masuk otomatis via Eloquent Event
            ])
            ->recordActions([
                // Memanggil tombol Edit untuk memicu Form Modal
                EditAction::make()
                    ->label('Tandai / Edit')
                    ->icon('heroicon-m-pencil-square'),
            ])
            ->toolbarActions([
                //
            ])
            ->paginated(false); // Semua siswa dalam 1 rombel tampil tanpa harus pindah halaman
    }
}
