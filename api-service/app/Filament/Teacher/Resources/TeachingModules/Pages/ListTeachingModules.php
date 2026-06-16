<?php

namespace App\Filament\Teacher\Resources\TeachingModules\Pages;

use App\Filament\Teacher\Resources\TeachingModules\TeachingModuleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListTeachingModules extends ListRecords
{
    protected static string $resource = TeachingModuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
