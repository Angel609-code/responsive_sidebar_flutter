import 'package:animated_tree_view/animated_tree_view.dart';

import '../models/menu_model.dart';

TreeNode<MenuModel> buildMenuTree(List<MenuModel> menuData, bool filter, String currentNode) {
  Map<int, TreeNode<MenuModel>> nodeMap = {};
  Map<int, TreeNode<MenuModel>> moduleMap = {};
  final rootNode = TreeNode<MenuModel>.root();

  if (!filter || currentNode == '99999999') {
    rootNode.addAll([
      TreeNode<MenuModel>(
        key: '99999999',
        data: MenuModel(id: 99999999, nombre: 'Inicio', url: 'bienvenidos', menuId: 0, orden: 1, moduloId: 0, migrated: false),
      )
    ]);
  }

  // Agrega los nodos de los modulos
  int index = 1;
  menuData.where((item) => item.moduloId == 0 && item.menuId == 0).forEach((item) {
    moduleMap[index] = createNode(MenuModel(
      id: item.id,
      nombre: item.nombre,
      url: item.url,
      menuId: 0,
      orden: 1,
      moduloId: 0,
      migrated: item.migrated,
    ));
    rootNode.addAll([moduleMap[index]!]);
    index++;
  });

  // Agrega los nodos de los submodulos
  for (var moduleKey in moduleMap.keys) {
    var parentNode = moduleMap[moduleKey];
    if (parentNode != null) {
      var moduleId = moduleMap[moduleKey]!.data!.id - 99990;
      for (var item in menuData.where((item) => item.moduloId == moduleId && item.menuId == 0)) {
        var childNode = createNode(item);
        parentNode.addAll([childNode]);
        nodeMap[item.id] = childNode;
      }
    }
  }

  // Agrega los nodos correspendientes a los menus
  for (var item in menuData.where((item) => item.menuId == 0)) {
    setChilds(item.id, menuData, nodeMap);
  }

  return rootNode;
}

/// Método encargado de crear un TreeNode<MenuModel>
TreeNode<MenuModel> createNode(MenuModel item) {
  return TreeNode<MenuModel>(
    key: item.id.toString(),
    data: item,
  );
}

/// Método recursivo que llena los nodos por cada elemento del sub elemento principal del menu
void setChilds(int parentId, List<MenuModel> menuData, Map<int, TreeNode<MenuModel>> nodeMap) {
  for (var item in menuData.where((item) => item.menuId == parentId)) {
    var parentNode = nodeMap[parentId];
    if (parentNode != null) {
      var childNode = createNode(item);
      nodeMap[item.id] = childNode;
      parentNode.add(childNode);
      setChilds(item.id, menuData, nodeMap);
    }
  }
}
