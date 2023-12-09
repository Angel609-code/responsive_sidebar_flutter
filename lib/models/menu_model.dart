class MenuModel {
  int id;
  String nombre;
  String url;
  int menuId;
  int orden;
  int moduloId;
  bool migrated;

  MenuModel({
    required this.id,
    required this.nombre,
    required this.url,
    required this.menuId,
    required this.orden,
    required this.moduloId,
    required this.migrated,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        url: json['url'] as String,
        menuId: json['menu_id'] == null ? 0 : json['menu_id'] as int,
        orden: json['orden'] as int,
        moduloId: json['modulo_id'] as int,
        migrated: json['migrated'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'url': url,
        'menuId': menuId,
        'orden': orden,
        'moduloId': moduloId,
        'migrated': migrated,
      };
}
