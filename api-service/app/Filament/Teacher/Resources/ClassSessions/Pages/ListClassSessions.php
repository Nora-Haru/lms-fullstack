<?php

namespace App\Filament\Teacher\Resources\ClassSessions\Pages;

use App\Filament\Teacher\Resources\ClassSessions\ClassSessionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListClassSessions extends ListRecords
{
    protected static string $resource = ClassSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
