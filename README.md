# VoxelBreak

Игра на Godot 4.4 (GDScript).
- Воксельный мир 32×32×32.
- Меш строится через `ArrayMesh` + `SurfaceTool`.
- Коллизия — `ConcavePolygonShape3D`.
- Обломки — `RigidBody3D` с `BoxMesh` (максимум 30 штук).
- Игрок — `CharacterBody3D` (WASD, пробел, мышь).
- Выстрел — луч через `PhysicsDirectSpaceState3D.intersect_ray()`.

## Структура
- `main.tscn` — основная сцена.
- `scripts/chunk.gd` — логика чанка и меша.
- `scripts/player.gd` — управление и выстрел.
- `scripts/debris.gd` — обломки.
- `project.godot` — настройки проекта (Forward+).

## Как запустить
1. Установите Godot 4.4.
2. Откройте папку `/home/user/voxelbreak`.
3. Запустите `project.godot`.

## Технические детали
- **Архитектура**: `PackedByteArray` (1 = блок, 0 = пусто).
- **Меш**: `ArrayMesh` + `SurfaceTool` (рисуем только видимые грани).
- **Коллизия**: `ConcavePolygonShape3D` обновляется вместе с мешем.
- **Разрушение**: удаляем воксели в радиусе 2, перестраиваем только чанк.
- **Обломки**: `RigidBody3D` с `BoxMesh` (лимит 30 штук).
- **Управление**: WASD (движение), Пробел (прыжок), Мышь (камера), ЛКМ (выстрел).
