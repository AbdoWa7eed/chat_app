import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

Widget getDialogWidget(BuildContext context,
    {required String animatedImage,
    required String title,
    bool isConfirmation = false}) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    child: Dialog(
      elevation: AppSize.s1_5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s14)),
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: BoxDecoration(
              color: ColorManager.backgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(AppSize.s14),
              boxShadow: const [BoxShadow(color: Colors.black26)]),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(animatedImage),
                const SizedBox(
                  height: AppSize.s20,
                ),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
                if (isConfirmation) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPadding.p20),
                      child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(AppStrings.ok).tr())),
                    ),
                  )
                ]
              ],
            ),
          )),
    ),
  );
}

String validateTime(String dateTime) {
  var formatter = DateTime.parse(dateTime);
  var difference = DateTime.now().difference(formatter);
  if (difference.inHours >= 24 && difference.inHours < 48) {
    return AppStrings.yesterday.tr();
  } else if (difference.inHours >= 48) {
    return DateFormat('yyyy-MM-dd').format(formatter);
  } else {
    return DateFormat("h:mma").format(formatter).toString();
  }
}

Widget appBarLeading({required Function() onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
    child: IconButton(
      icon: Icon(Icons.arrow_back_ios,
          size: AppSize.s20, color: ColorManager.black),
      onPressed: onPressed,
    ),
  );
}

showPicker(BuildContext context, ChatAppCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
            child: Container(
          color: ColorManager.backgroundColor,
          child: Wrap(
            children: [
              ListTile(
                trailing:
                    const Icon(Icons.arrow_forward_ios, size: AppSize.s18),
                leading: const Icon(Icons.camera),
                title: const Text(AppStrings.fromGallery).tr(),
                onTap: () {
                  cubit.imageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                trailing:
                    const Icon(Icons.arrow_forward_ios, size: AppSize.s18),
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(AppStrings.fromCamera).tr(),
                onTap: () {
                  cubit.imageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget getUsersListWidget(ChatAppCubit cubit) { 
    return Expanded(
      child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
              return _getUserItem(context ,cubit.users[index], cubit, index);
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSize.s6),
          itemCount: cubit.users.length),
    );
}

  Widget _getUserItem(context , UserModel user, ChatAppCubit cubit, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12, vertical: AppPadding.p8),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSize.s25,
            backgroundImage: NetworkImage(user.imageLink),
            backgroundColor: ColorManager.darkGray,
          ),
          const SizedBox(
            width: AppSize.s10,
          ),
          Expanded(
            child: Text(
              user.nickName,
              maxLines: AppConstants.minLines,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Checkbox(
            value: cubit.checkedUsers[index] ?? false,
            onChanged: (value) {
              cubit.addCheckedStateToMap(index, value);
            },
          ),
        ],
      ),
    );
  }
