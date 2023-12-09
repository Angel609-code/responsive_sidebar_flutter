import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sidebar_01/constants/color_constants.dart';

import '../blocs/Menu/menu_bloc.dart';
import '../blocs/Menu/menu_event.dart';
import '../blocs/Menu/menu_service.dart';
import '../blocs/Menu/menu_state.dart';
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

  bool expanded = true;
  bool activatedHover = false;
  List<bool> moduleExpanded = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  void toggleMenu() {
    setState(() {
      moduleExpanded.clear();
      expanded = !expanded;
    });
  }

  void toggleModules([int? index, bool? isTap]) {
    setState(
      () {
        // Cerrar cada modulo abierto que no corresponda con el elemento actual
        for (var i = 0; i < moduleExpanded.length; i++) {
          if (moduleExpanded[i] && i != index) {
            moduleExpanded[i] = false;
          }
        }

        if (index != null) {
          if (moduleExpanded[index] && activatedHover && isTap != null && isTap) {
            moduleExpanded[index] = false;
            activatedHover = false;
          } else if (isTap != null && isTap && !activatedHover) {
            activatedHover = true;
            moduleExpanded[index] = !moduleExpanded[index];
          }else{
            moduleExpanded[index] = !moduleExpanded[index];
          }
        }
      },
    );
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
          ),
        ],
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoadingState) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: ColorConstants.secondaryText,
                    width: expanded ? 260 : 50,
                    child: Column(
                      children: [
                        _searchInput(context),
                        // Sidebar menu widget
                        Expanded(
                          child: Container(
                            color: ColorConstants.secondaryText,
                            child: TreeView.simpleTyped<MenuModel,
                                TreeNode<MenuModel>>(
                              key: const Key('menuTree'),
                              tree: TreeNode(),
                              showRootNode: false,
                              shrinkWrap: true,
                              expansionBehavior:
                                  ExpansionBehavior.collapseOthers,
                              indentation: const Indentation(width: 0),
                              expansionIndicatorBuilder: (context, node) {
                                return ChevronIndicator.rightDown(
                                  alignment: Alignment.centerRight,
                                  tree: node,
                                  color: Colors.white,
                                  icon: Icons.arrow_right,
                                );
                              },
                              onItemTap: (item) {},
                              builder: (context, node) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Scaffold(
                          appBar: CustomAppBar(
                            isExpanded: expanded,
                            onToggleMenu: toggleMenu,
                          ),
                          body: const Text('Data'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is MenuSuccessState) {
              TreeNode<MenuModel> menuTree = buildMenuTree(
                state.menu,
                state.filter,
                state.node,
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: ColorConstants.secondaryText,
                    width: expanded ? 260 : 50,
                    child: Column(
                      children: [
                        _searchInput(context, state),
                        // Sidebar menu widget
                        Expanded(
                          child: Container(
                            color: ColorConstants.secondaryText,
                            child: _paintMenu(context, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scaffold(
                      appBar: CustomAppBar(
                        isExpanded: expanded,
                        onToggleMenu: toggleMenu,
                      ),
                      body: Stack(
                        children: [
                          GestureDetector(
                            child: const Text('Data'),
                            onTap: () {
                              toggleModules();
                            }
                          ),
                          ...List.generate(
                            menuTree.children.length,
                            (index) {
                              try {
                                moduleExpanded[index];
                              } catch (e) {
                                return const SizedBox();
                              }

                              TreeNode<MenuModel> currentNode =
                                  menuTree.children.values.elementAt(index)
                                      as TreeNode<MenuModel>;
                                      
                              final newRootNode = TreeNode<MenuModel>.root();
                              newRootNode.add(currentNode);

                              return Positioned(
                                left: 0,
                                top: 2 + (index * 50),
                                child: AnimatedContainer(
                                  alignment: Alignment.centerLeft,
                                  duration: const Duration(milliseconds: 120),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  width: moduleExpanded[index] ? 250 : 0,
                                  decoration: const BoxDecoration(
                                    color: ColorConstants.secondaryText,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6.0),
                                      bottomRight: Radius.circular(6.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4.0,
                                        spreadRadius: 0.0,
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                  ),
                                  // Your popup content here
                                  child: Container(
                                    color: ColorConstants.secondaryText,
                                    child: TreeView.simpleTyped<MenuModel,
                                        TreeNode<MenuModel>>(
                                      key: const Key('menuTree'),
                                      tree: newRootNode,
                                      showRootNode: false,
                                      shrinkWrap: true,
                                      expansionBehavior:
                                          ExpansionBehavior.collapseOthers,
                                      indentation: const Indentation(
                                          width: 20,
                                          color: Colors.transparent),
                                      expansionIndicatorBuilder:
                                          (context, node) {
                                        return ChevronIndicator.rightDown(
                                          alignment: Alignment.centerRight,
                                          tree: node,
                                          color: Colors.white,
                                          icon: Icons.arrow_right,
                                        );
                                      },
                                      onItemTap: (item) {
                                        // if (item.data!.url != '/') {
                                        //   toggleModules();
                                        //   context.read<MenuBloc>().add(
                                        //         LoadMenuEvent(
                                        //           menu: state.menu,
                                        //           currentNode: item.data!.id
                                        //               .toString(),
                                        //           filter: _searchController
                                        //                       .text ==
                                        //                   ''
                                        //               ? false
                                        //               : true,
                                        //         ),
                                        //       );
                                        //   context.read<IframeBloc>().add(
                                        //         IframeContentEvent(
                                        //           path: item.data!.url,
                                        //           isMigrated:
                                        //               item.data!.migrated,
                                        //         ),
                                        //       );
                                        // }
                                      },
                                      builder: (context, node) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          color: ColorConstants.secondaryText,
                                          width: 250,
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
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is MenuErrorState) {
              return const Center(
                child: Text(
                  'An error has occurred. Please try again later.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Container _searchInput(BuildContext context, [MenuSuccessState? state]) {
    if (!expanded) {
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
          ));
    }
    return Container(
      color: ColorConstants.secondaryText,
      width: 250,
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
            TextField(
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
              onSubmitted: (value) {
                if (state != null) {
                  context.read<MenuBloc>().add(
                        UpdateMenuEvent(
                          state.menu,
                          value,
                          filter: value == '' ? false : true,
                        ),
                      );
                }
              },
              controller: _searchController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paintMenu(BuildContext ctx, MenuSuccessState state) {
    if (!expanded) {
      TreeNode<MenuModel> menuTree = buildMenuTree(
        state.menu,
        state.filter,
        state.node,
      );

      return Container(
        color: ColorConstants.secondaryText,
        child: ListView.builder(
          itemCount: menuTree.children.length,
          itemBuilder: (context, index) {
            try {
              moduleExpanded[index];
            } catch (e) {
              moduleExpanded.add(false);
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  width: 44,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: moduleExpanded[index] ? ColorConstants.tertiaryGrayColor : Colors.transparent,
                  ),
                  child: InkWell(
                    child: const Icon(
                      Icons.pages,
                      color: Colors.white,
                    ),
                    onTap: () {
                      toggleModules(index, true);
                    },
                    onHover: (value){
                      if(value && activatedHover) toggleModules(index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return TreeView.simpleTyped<MenuModel, TreeNode<MenuModel>>(
      key: const Key('menuTree'),
      tree: buildMenuTree(
        state.menu,
        state.filter,
        state.node,
      ),
      showRootNode: false,
      shrinkWrap: true,
      expansionBehavior: ExpansionBehavior.collapseOthers,
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
          ctx.read<MenuBloc>().add(
                LoadMenuEvent(
                  menu: state.menu,
                  currentNode: item.data!.id.toString(),
                  filter: _searchController.text == '' ? false : true,
                ),
              );
          // ctx.read<IframeBloc>().add(
          //       IframeContentEvent(
          //         path: item.data!.url,
          //         isMigrated: item.data!.migrated,
          //       ),
          //     );
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
            width: expanded ? 260 : 50,
            alignment: Alignment.center,
            child: Padding(
              padding: node.level == 2
                  ? const EdgeInsets.only(
                      left: 30,
                    )
                  : node.level == 3
                      ? const EdgeInsets.only(
                          left: 35,
                        )
                      : node.level >= 4
                          ? const EdgeInsets.only(
                              left: 40,
                            )
                          : const EdgeInsets.only(
                              left: 0,
                            ),
              child: Container(
                width: 260,
                height: 45,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: isSelected
                      ? node.isLeaf
                          ? ColorConstants.primary
                          : null
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
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
                            expanded
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
                                : Container()
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
}
