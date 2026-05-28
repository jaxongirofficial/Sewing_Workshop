import '../../../../l10n/s.dart';
import '../../../workshop/models/workshop_mock_models.dart';

String categoryLabel(WarehouseCategory category, S s) => switch (category) {
  WarehouseCategory.clothing => s.categoryClothing,
  WarehouseCategory.material => s.categoryMaterial,
  WarehouseCategory.accessory => s.categoryAccessory,
  WarehouseCategory.other => s.categoryOther,
};

String warehouseItemName(WarehouseItem item, S s) => switch (item.id) {
  'w-1' => s.productPants,
  'w-2' => s.productDress,
  'w-3' => s.productSleeve,
  'w-4' => s.productSkirt,
  'w-5' => s.productJacket,
  'w-6' => s.productBag,
  'w-7' => s.productBelt,
  'w-8' => s.productBlueFabric,
  'w-9' => s.productWhiteThread,
  'w-10' => s.productButton,
  _ => item.name,
};

String unitLabel(String unit, S s) => switch (unit) {
  'ta' => s.unitPiece,
  'metr' => s.unitMeter,
  'dona' => s.unitItem,
  _ => unit,
};
