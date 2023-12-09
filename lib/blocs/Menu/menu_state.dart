import 'package:equatable/equatable.dart';

import '../../models/menu_model.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];

  get temp => null;
}

class MenuInitialState extends MenuState {}

class MenuLoadingState extends MenuState {}

class MenuSuccessState extends MenuState {
  final List<MenuModel> menu;
  final String node;
  final bool filter;

  const MenuSuccessState(this.menu, {this.node = '', this.filter = false});

  @override
  List<Object> get props => [menu,node,filter];
}

class MenuErrorState extends MenuState {
  final String errMessage;

  const MenuErrorState(this.errMessage);

  @override
  List<Object> get props => [errMessage];
}
