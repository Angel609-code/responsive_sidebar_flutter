import 'package:equatable/equatable.dart';

import '../../models/menu_model.dart';

abstract class MenuEvent extends Equatable {}

class InitEvent extends MenuEvent {
  InitEvent();
  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String currentNode;
  final List<MenuModel> menu;
  final bool filter;

  LoadMenuEvent({this.currentNode = '', this.menu = const [], this.filter = false});

  @override
  List<Object?> get props => [];
}

class UpdateMenuEvent extends MenuEvent {
  final String searchMenu;
  final List<MenuModel> updatedMenu;
  final bool filter;

  UpdateMenuEvent(this.updatedMenu,this.searchMenu,{this.filter = false});

  @override
  List<Object?> get props => [updatedMenu,searchMenu];
}

class CurrentNodeEvent extends MenuEvent {
  final String node;

  CurrentNodeEvent(this.node);

  @override
  List<Object?> get props => [node];
}
