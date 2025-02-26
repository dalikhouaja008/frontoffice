import 'package:flutter/material.dart';
import 'package:the_boost/core/utils/constants.dart';
import '../../../domain/entities/user.dart';
import '../../pages/login_screen.dart';

class MenuItemData {
  final String title;
  final IconData icon;

  MenuItemData({required this.title, required this.icon});
}

class AppMenu extends StatefulWidget {
  final User? user;
  final VoidCallback? on2FAButtonPressed;
  final int selectedIndex;
  final Function(int) onMenuItemSelected;

  const AppMenu({
    Key? key, 
    required this.user, 
    required this.on2FAButtonPressed, 
    required this.selectedIndex,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  int hoverIndex = 0;

  final List<MenuItemData> menuItems = [
    MenuItemData(title: "Accueil", icon: Icons.home_rounded),
    MenuItemData(title: "Terrains", icon: Icons.landscape_rounded),
    MenuItemData(title: "Favoris", icon: Icons.favorite_rounded),
    MenuItemData(title: "Messages", icon: Icons.message_rounded),
  ];

  @override
  void initState() {
    super.initState();
    hoverIndex = widget.selectedIndex;
  }

  Widget buildMenuItem(int index) {
    final item = menuItems[index];
    final isSelected = widget.selectedIndex == index;
    final isHovered = hoverIndex == index;

    return Flexible(
      child: InkWell(
        onTap: () => widget.onMenuItemSelected(index),
        onHover: (value) {
          setState(() {
            hoverIndex = value ? index : widget.selectedIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(minWidth: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected ? kPrimaryColor : kTextLightColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? kPrimaryColor : kTextLightColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected || isHovered)
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [kDefaultShadow],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "The Boost",
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Menu Items
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(menuItems.length, (index) => buildMenuItem(index)),
            ),
          ),
          // Bouton 2FA si non activé
          if (!widget.user!.isTwoFactorEnabled)
            IconButton(
              icon: const Icon(Icons.security_outlined),
              onPressed: widget.on2FAButtonPressed,
              tooltip: 'Activer 2FA',
              color: Colors.orange,
            ),
          // Profile Section
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryColor,
                  child: Text(
                    widget.user!.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user!.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    Text(
                      widget.user!.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: kTextLightColor,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}