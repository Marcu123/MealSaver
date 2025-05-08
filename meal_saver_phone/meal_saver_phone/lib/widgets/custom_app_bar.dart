import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/widgets/search_dialog.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const CustomAppBar({super.key, required this.title, this.showBack = true});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await ApiService().getCurrentUser();
    if (mounted && data != null) {
      setState(() {
        profileImageUrl = data['profileImageUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: widget.showBack,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            showDialog(context: context, builder: (_) => const SearchDialog());
          },
        ),
        if (widget.title == "Home")
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/profile");
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage("assets/images/logo.png")
                            as ImageProvider,
              ),
            ),
          ),
      ],
    );
  }
}
