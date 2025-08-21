import "package:flutter/material.dart";
import "package:manong_application/theme/colors.dart";

class AppBarSearch extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function()? onBackTap;
  final TextEditingController? controller;
  final Function(String) onChanged;

  const AppBarSearch({
    super.key,
    required this.title,
    this.onBackTap,
    this.controller,
    required this.onChanged,
  });

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}

class _AppBarSearchState extends State<AppBarSearch> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(61, 104, 196, 1),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBackTap,
            child: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: SizedBox(
              height: 36,
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: AppColorScheme.royalBlue,
                    selectionHandleColor: AppColorScheme.royalBlue,
                  ),
                ),
                child: TextField(
                  cursorColor: AppColorScheme.royalBlue,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
