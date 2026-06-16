<?php

namespace App\Filament\Teacher\Resources\TeachingModules\Pages;

use App\Filament\Teacher\Resources\TeachingModules\TeachingModuleResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditTeachingModule extends EditRecord
{
    protected static string $resource = TeachingModuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
