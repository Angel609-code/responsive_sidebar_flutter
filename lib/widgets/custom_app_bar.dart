import 'package:flutter/material.dart';
import 'package:sidebar_01/utils/num_extensions.dart';

import '../constants/color_constants.dart';

class CustomAppBar extends AppBar {
  final bool isExpanded;
  final VoidCallback onToggleMenu;

  CustomAppBar({
    super.key,
    required this.isExpanded,
    required this.onToggleMenu,
  });

  @override
  State<AppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: AppBar(
        backgroundColor: ColorConstants.secondaryText,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
              widget.isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: ColorConstants.primary),
          onPressed: widget.onToggleMenu,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard_outlined,
              color: ColorConstants.primary,
            ),
            7.pw,
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Text('Login'),
                ),
              );
            },
            icon: const Icon(
              Icons.logout_outlined,
              color: ColorConstants.primary,
            ),
          )
        ],
      ),
    );
  }
}
