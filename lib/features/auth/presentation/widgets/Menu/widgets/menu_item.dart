import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/constants.dart';

class MenuItemData {
  final String title;
  final IconData icon;

  MenuItemData({required this.title, required this.icon});
}

class MenuItem extends StatelessWidget {
  final MenuItemData item;
  final bool isSelected;
  final bool isHovered;
  final Function() onTap;
  final Function(bool) onHover;

  const MenuItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
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
}