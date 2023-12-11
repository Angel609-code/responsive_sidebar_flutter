import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sidebar_01/blocs/Menu/menu_event.dart';
import 'package:sidebar_01/blocs/Menu/menu_service.dart';

import '../blocs/Menu/menu_bloc.dart';
import '../blocs/Menu/menu_state.dart';
import '../constants/color_constants.dart';
import '../models/menu_model.dart';
import '../utils/menu.dart';
import 'custom_app_bar.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  late TextEditingController _searchController;

  bool expanded = false;
  bool isMobile = false;
  bool itWasClicked = false;
  int positionedMenuItemIndexSelected = -1;
  Timer? _debounceTimer;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void toggleMenu() {
    setState(() {
      expanded = !expanded;
      positionedMenuItemIndexSelected = -1;
    });
  }

  void toogleItWasClicked([bool? value]) {
    setState(() {
      itWasClicked = value ?? !itWasClicked;
    });
  }

  void togglePositionedMenuItem(int index) {
    setState(() {
      positionedMenuItemIndexSelected = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double screenSize = MediaQuery.of(context).size.width;

    setState(() {
      isMobile = screenSize < 768;
    });

    if (!isMobile) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MenuBloc(
              MenuService(),
            )..add(
                LoadMenuEvent(),
              ),
          )
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Container(
                color: ColorConstants.secondaryText,
                width: expanded ? 260 : 50,
                child: BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _searchInput(context, state),
                        Expanded(
                          child: SingleChildScrollView(
                            child: expanded
                                ? _animatedTreeView(context, state)
                                : _sideMenuItems(context, state),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            Expanded(
              child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomAppBar(
                  isExpanded: expanded,
                  onToggleMenu: toggleMenu,
                  isMobile: isMobile,
                ),
                drawer: isMobile
                    ? Drawer(
                        clipBehavior: Clip.none,
                        child: BlocBuilder<MenuBloc, MenuState>(
                          builder: (context, state) {
                            return Container(
                              color: ColorConstants.secondaryText,
                              child: Column(
                                children: [
                                  _searchInput(context, state),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: _animatedTreeView(context, state),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : null,
                body: Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        toogleItWasClicked(false);
                        togglePositionedMenuItem(-1);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: Text('Data'),
                        ),
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    BlocBuilder<MenuBloc, MenuState>(
                      builder: (context, state) {
                        return _stackedMenu(context, state);
                      },
                    ),
                  ],
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchInput(BuildContext context, MenuState state) {
    if (!expanded && !isMobile) {
      return Container(
        color: ColorConstants.secondaryText,
        width: 50,
        height: 50,
        child: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            toggleMenu();
          },
        ),
      );
    }

    return Container(
      color: ColorConstants.secondaryText,
      width: isMobile ? 290 : 250,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          left: 12,
          right: 12,
          bottom: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: ColorConstants.secondaryText,
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Búsqueda de pantallas',
                  hintStyle: TextStyle(color: Colors.white30),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                onChanged: (value) {
                  if (_debounceTimer?.isActive ?? false) {
                    _debounceTimer?.cancel();
                  }
                  _debounceTimer = Timer(const Duration(milliseconds: 550), () {
                    context.read<MenuBloc>().add(
                          UpdateMenuEvent(
                            (state is MenuSuccessState) ? state.menu : const [],
                            value,
                            filter: value == '' ? false : true,
                          ),
                        );
                  });
                },
                controller: _searchController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paintMenu(BuildContext context, MenuSuccessState state) {
    return TreeView.simpleTyped<MenuModel, TreeNode<MenuModel>>(
      key: const Key('menuTree'),
      tree: buildMenuTree(
        state.menu,
        state.filter,
        state.node,
      ),
      showRootNode: false,
      shrinkWrap: true,
      expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
      indentation: const Indentation(width: 0),
      expansionIndicatorBuilder: (context, node) {
        return ChevronIndicator.rightDown(
          alignment: Alignment.centerRight,
          tree: node,
          color: Colors.white,
          icon: Icons.arrow_right,
        );
      },
      onItemTap: (item) {
        if (item.data!.url != '/') {
          context.read<MenuBloc>().add(
                LoadMenuEvent(
                  menu: state.menu,
                  currentNode: item.data!.id.toString(),
                  filter: _searchController.text == '' ? false : true,
                ),
              );

          if (isMobile) Scaffold.of(context).closeDrawer();
        }
      },
      builder: (context, node) {
        bool isSelected = state.node == node.key;
        final isExpanded = node.isExpanded;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            color: node.level >= 2 || isExpanded
                ? ColorConstants.tertiaryGrayColor
                : ColorConstants.secondaryText,
            height: 42,
            // Padding between one menu and another.
            width: isMobile
                ? null
                : expanded
                    ? 260
                    : 50,
            alignment: Alignment.center,
            child: Padding(
              padding: node.level == 1
                  ? EdgeInsets.symmetric(
                      horizontal: isMobile ? 10.0 : 0.0,
                      vertical: isMobile ? 2.0 : 0.0,
                    )
                  : node.level == 2
                      ? EdgeInsets.only(
                          left: 30,
                          right: isMobile ? 20.0 : 0.0,
                        )
                      : node.level == 3
                          ? EdgeInsets.only(
                              left: 35, right: isMobile ? 20.0 : 0.0)
                          : node.level >= 4
                              ? EdgeInsets.only(
                                  left: 40, right: isMobile ? 20.0 : 0.0)
                              : EdgeInsets.only(
                                  left: 0, right: isMobile ? 20.0 : 0.0),
              child: Container(
                width: isMobile ? null : 260,
                height: 45,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: isSelected
                      ? node.isLeaf
                          ? ColorConstants.primary
                          : null
                      : null,
                  borderRadius: isMobile
                      ? isSelected
                          ? node.isLeaf
                              ? BorderRadius.circular(5)
                              : null
                          : null
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: node.level >= 2
                      ? Text(
                          node.data!.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        )
                      : Row(
                          children: [
                            node.data!.menuId == 0
                                ? const Icon(
                                    Icons.pages,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : Container(),
                            const SizedBox(
                              width: 6,
                            ),
                            expanded || isMobile
                                ? SizedBox(
                                    width: 200,
                                    child: Text(
                                      node.data!.nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      softWrap: true,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _animatedTreeView(BuildContext context, MenuState state) {
    if (state is MenuSuccessState) {
      if (state.menu.isNotEmpty) {
        return _paintMenu(context, state);
      }

      return const Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    if (state is MenuErrorState) {
      return const Center(
        child: Text(
          'Ocurrió un error al cargar el menú',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _sideMenuItems(BuildContext context, MenuState state) {
    if (state is MenuSuccessState) {
      if (state.menu.isEmpty) {
        return Container();
      }

      TreeNode<MenuModel> treeMenu = buildMenuTree(
        state.menu,
        state.filter,
        state.node,
      );

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
            treeMenu.children.values.length,
            (index) => Container(
                  padding: const EdgeInsets.all(6.0),
                  width: 44,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: ColorConstants.secondaryText,
                  ),
                  child: _sideMenuItem(
                      context,
                      treeMenu.children.values.elementAt(index)
                          as TreeNode<MenuModel>,
                      index),
                )),

        // [
        //   ...treeMenu.children.values.map((node) => Container(
        //       padding: const EdgeInsets.all(6.0),
        //       width: 44,
        //       height: 50,
        //       decoration: const BoxDecoration(
        //         color: ColorConstants.secondaryText,
        //       ),
        //       child: _sideMenuItem(context, node as TreeNode<MenuModel>),
        //     )
        //   ),
        //   for (var node in treeMenu.children.values)
        //     Container(
        //       padding: const EdgeInsets.all(6.0),
        //       width: 44,
        //       height: 50,
        //       decoration: const BoxDecoration(
        //         color: ColorConstants.secondaryText,
        //       ),
        //       child: _sideMenuItem(context, node as TreeNode<MenuModel>),
        //     )
        // ],
      );
    }

    return Container();
  }

  Widget _sideMenuItem(
      BuildContext context, TreeNode<MenuModel> node, int index) {
    return Material(
      color: ColorConstants.secondaryText,
      child: Container(
        decoration: BoxDecoration(
          color: (positionedMenuItemIndexSelected == index)
              ? ColorConstants.tertiaryGrayColor
              : ColorConstants.secondaryText,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          child: const Icon(
            Icons.pages,
            color: Colors.white,
          ),
          onTap: () {
            toogleItWasClicked();
            togglePositionedMenuItem(itWasClicked ? index : -1);
          },
          onHover: (hovered) {
            if (hovered && itWasClicked) {
              togglePositionedMenuItem(index);
            }
          },
        ),
      ),
    );
  }

  Widget _stackedMenu(BuildContext context, MenuState state) {
    if (state is MenuSuccessState) {
      if (state.menu.isEmpty) {
        return Container();
      }

      TreeNode<MenuModel> treeMenu = buildMenuTree(
        state.menu,
        state.filter,
        state.node,
      );

      return Stack(
        children: [
          ...List.generate(
            treeMenu.children.length,
            (index) {
              var currentNode = treeMenu.children.values.elementAt(index)
                  as TreeNode<MenuModel>;

              return _PositionedTreeView(
                index: index,
                currentSelectedIndex: positionedMenuItemIndexSelected,
                currentNode: currentNode,
                menu: state.menu,
                searchText: _searchController.text,
                node: state.node,
              );
            },
          ),
        ],
      );
    }

    return Container();
  }
}

class _PositionedTreeView extends StatefulWidget {
  const _PositionedTreeView({
    required this.index,
    required this.currentSelectedIndex,
    required this.currentNode,
    required this.menu,
    required this.searchText,
    required this.node,
  });

  final int index;
  final int currentSelectedIndex;
  final TreeNode<MenuModel> currentNode;
  final List<MenuModel> menu;
  final String searchText;
  final String node;

  @override
  State<_PositionedTreeView> createState() => _PositionedTreeViewState();
}

class _PositionedTreeViewState extends State<_PositionedTreeView> {
  bool isExpanded = false;

  @override
  void didUpdateWidget(_PositionedTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    isExpanded = widget.currentSelectedIndex == widget.index;
  }

  void togglePopup() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    TreeNode<MenuModel> newRootNode = TreeNode<MenuModel>.root();
    double widgetSize = 60.0;
    double currentYPosition = widget.index * 50.0 + 2;
    double maxHeight = MediaQuery.of(context).size.height;
    double widgetWidth = 250;

    if (!widget.currentNode.isLeaf) {
      for (var element in widget.currentNode.children.values) {
        newRootNode.add(element);
      }
      widgetSize = widget.currentNode.children.length * 55.0;
    }

    if (widget.currentSelectedIndex == widget.index) {
      if (widgetSize > maxHeight - 52) {
        widgetSize = maxHeight - 82.0;
      }

      if (currentYPosition + widgetSize > maxHeight) {
        currentYPosition = maxHeight - widgetSize - 52;
      }
    }

    return Positioned(
      top: currentYPosition,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        width: isExpanded ? widgetWidth : 0,
        height: isExpanded ? widgetSize : 0,
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: ColorConstants.secondaryText,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          minWidth: widgetWidth,
          maxWidth: widgetWidth,
        ),
        child: widget.currentNode.isLeaf
            ? SizedBox(
                width: widgetWidth,
                child: InkWell(
                  onTap: () {
                    context.read<MenuBloc>().add(
                          LoadMenuEvent(
                            menu: widget.menu,
                            currentNode: widget.currentNode.data!.id.toString(),
                            filter: widget.searchText == '' ? false : true,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    width: widgetWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: widget.node == widget.currentNode.key
                          ? ColorConstants.primary
                          : ColorConstants.secondaryText,
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 50,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.currentNode.data!.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
              )
            : ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all<Color>(
                    Colors.white.withOpacity(0.5),
                  ),
                ),
                child: TreeView.simpleTyped<MenuModel, TreeNode<MenuModel>>(
                  tree: newRootNode,
                  showRootNode: false,
                  shrinkWrap: true,
                  expansionBehavior:
                      ExpansionBehavior.collapseOthersAndSnapToTop,
                  indentation:
                      const Indentation(width: 20.0, color: Colors.transparent),
                  expansionIndicatorBuilder: (context, node) {
                    return ChevronIndicator.rightDown(
                      alignment: Alignment.centerRight,
                      tree: node,
                      color: Colors.white,
                      icon: Icons.arrow_right,
                    );
                  },
                  onItemTap: (item) {
                    if (item.data!.url != '/') {
                      context.read<MenuBloc>().add(
                            LoadMenuEvent(
                              menu: widget.menu,
                              currentNode: item.data!.id.toString(),
                              filter: widget.searchText == '' ? false : true,
                            ),
                          );
                    }
                  },
                  builder: (context, node) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      width: widgetWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: widget.node == node.key
                            ? ColorConstants.primary
                            : node.isExpanded ?
                            ColorConstants.tertiaryGrayColor
                            :ColorConstants.secondaryText,
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 50,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        node.data!.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        softWrap: true,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
