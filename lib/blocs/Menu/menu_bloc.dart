import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sidebar_01/blocs/Menu/interface_menu_service.dart';

import '../../models/menu_model.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final IMenuService menuService;

  MenuBloc(this.menuService) : super(MenuInitialState()) {
    on<LoadMenuEvent>((event, emit) async {
      var username = 'admin';
      List<MenuModel> response = event.currentNode == '' ? await menuService.obtenerMenu(username: username, filterMenu: '') : event.menu;
      emit(MenuSuccessState(response, node: event.currentNode, filter: event.filter));
    });

    on<UpdateMenuEvent>((event, emit) async {
      emit(MenuLoadingState());
      var username = 'admin';

      List<MenuModel> response = await menuService.obtenerMenu(username: username, filterMenu: event.searchMenu);
      emit(MenuSuccessState(response, filter: event.filter));
    });
  }
}
