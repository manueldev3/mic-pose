import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:role_play/theme/role_play_theme.dart';

/// Sidebar widget
class Sidebar extends ConsumerWidget {
  const Sidebar({
    super.key,
    required this.onSizePressed,
    this.expand = true,
  });

  final bool expand;
  final VoidCallback onSizePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(microseconds: 300),
      child: SizedBox(
        width: expand ? 360 : 120,
        height: screenSize.height,
        child: Stack(
          children: [
            SizedBox(
              width: expand ? 360 : 120,
              height: screenSize.height,
            ),
            Image.asset(
              expand
                  ? "assets/sidebar-header-bg.png"
                  : "assets/sidebar-header-bg-compat.png",
              width: expand ? 340 : 100,
              fit: BoxFit.fitWidth,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(microseconds: 300),
              child: AnimatedContainer(
                width: expand ? 340 : 100,
                height: screenSize.height,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: RolePlayColors.backgroundSidebar.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    right: BorderSide(
                      width: 2,
                      color: RolePlayColors.borders,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.all(32).copyWith(bottom: 64),
                          child: SvgPicture.asset(
                            expand
                                ? "assets/brand/logo.svg"
                                : "assets/brand/icon.svg",
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                          child: expand
                              ? FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(200, 64),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.video_call_rounded),
                                  label: const Text(
                                    "Role Play",
                                  ),
                                )
                              : IconButton.filled(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(64, 64),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.video_call_rounded,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        Visibility(
                          visible: expand,
                          child: Column(
                            children: ListTile.divideTiles(
                              color: Colors.transparent,
                              tiles: [
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/home.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Home"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/book_5.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Library"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/team_dashboard.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Dashboard"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/menu_book.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Exercises"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/supervised_user_circle.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Tutors"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ).toList(),
                          ),
                        ),
                        Visibility(
                          visible: !expand,
                          child: Column(
                            children: ListTile.divideTiles(
                              color: Colors.transparent,
                              tiles: [
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/home.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/book_5.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/team_dashboard.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/menu_book.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/supervised_user_circle.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Visibility(
                          visible: expand,
                          child: Column(
                            children: ListTile.divideTiles(
                              color: Colors.transparent,
                              tiles: [
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/help.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Help guide"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icons/settings.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: const Text("Settings"),
                                  titleTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ).toList(),
                          ),
                        ),
                        Visibility(
                          visible: !expand,
                          child: Column(
                            children: ListTile.divideTiles(
                              color: Colors.transparent,
                              tiles: [
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/help.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: SvgPicture.asset(
                                    "assets/icons/settings.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ).toList(),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              color: RolePlayColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: expand
                                ? const EdgeInsets.all(13).copyWith(right: 0)
                                : const EdgeInsets.all(13),
                            margin: const EdgeInsets.all(16),
                            child: expand
                                ? Visibility(
                                    visible: expand,
                                    child: ListTile(
                                      leading: const Badge(
                                        label: Text("2"),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            "http://i.pravatar.cc/512",
                                          ),
                                        ),
                                      ),
                                      title: const Text("Jhon Doe"),
                                      subtitle: const Text("jhondoe@gmail.com"),
                                      titleTextStyle: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                      subtitleTextStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white38,
                                      ),
                                      trailing: InkWell(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.more_vert_rounded,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Badge(
                                    label: Text("2"),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        "http://i.pravatar.cc/512",
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: 0,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: RolePlayColors.backgroundSidebar,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      width: 2,
                      color: RolePlayColors.borders,
                    ),
                  ),
                ),
                onPressed: onSizePressed,
                icon: RotatedBox(
                  quarterTurns: -1,
                  child: Icon(expand ? Icons.unfold_less : Icons.unfold_more),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
