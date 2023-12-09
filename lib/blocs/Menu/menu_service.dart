import 'dart:developer';

import 'package:dio/dio.dart';

import '../../models/menu_model.dart';
import 'interface_menu_service.dart';

class MenuService extends IMenuService {
  MenuService();

  @override
  Future<dynamic> obtenerMenu({required String username, required String filterMenu}) async {
    try {
      // var headers = {
      //   'Authorization': 'Bearer 2ZK3PRmpM80c9TMXlYVFtVAE6qo_MoumkPXZhA5ub4Yw3QSJ'
      // };
      final dio = Dio();

      var response = await dio.request(
        'http://192.168.1.6:3000/getMenu/query?username=$username&searchTerm=$filterMenu',
        options: Options(
          method: 'GET',
          // headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        List<MenuModel> menuData = (response.data as List).map((e) => MenuModel.fromJson(e)).toList();
        return menuData;
      }
      return [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}