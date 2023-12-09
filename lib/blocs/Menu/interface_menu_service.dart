abstract class IMenuService {
  Future<dynamic> obtenerMenu({
    required String username,
    required String filterMenu
  });
}
