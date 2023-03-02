
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem{

  final String text;
  final Widget icon;

  MenuItem(this.text, this.icon);
}
class MenuItems {
  static List<MenuItem> items = [
    createGroupItem,
    settingsItem
  ];


  static MenuItem settingsItem  = MenuItem(
    AppStrings.settings, SvgPicture.asset(ImageAssets.settingsIc));

  static MenuItem createGroupItem = MenuItem(
    AppStrings.createNewGroup,  Icon(Icons.groups, 
    color: ColorManager.darkGray,));


 static PopupMenuItem<MenuItem> buildItem(MenuItem item , context){
  return PopupMenuItem(
    value: item,
    child: Row(
    children: [
      item.icon,
      const SizedBox(
        width: AppSize.s10,
      ),
      Text(item.text.tr() , 
      style: Theme.of(context).textTheme.titleLarge,),
    ],
  ));
 }
}