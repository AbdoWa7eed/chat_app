import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

void showPicker(BuildContext context,
    {required Function() onCameraTapped, required Function() onGalleryTapped}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
          child: Container(
        color: ColorManager.backgroundColor,
        child: Wrap(
          children: [
            ListTile(
              trailing: const Icon(Icons.arrow_forward_ios, size: AppSize.s18),
              leading: const Icon(Icons.camera),
              title: const Text(AppStrings.fromGallery).tr(),
              onTap: () {
                Navigator.of(context).pop();
                onGalleryTapped.call();
              },
            ),
            ListTile(
              trailing: const Icon(Icons.arrow_forward_ios, size: AppSize.s18),
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(AppStrings.fromCamera).tr(),
              onTap: () {
                Navigator.of(context).pop();
                onCameraTapped.call();
              },
            ),
          ],
        ),
      ));
    },
  );
}

Widget getUsersListWidget(
  ChatAppCubit cubit, {
  required Function(bool?, int) onChanged,
  required Map<int, bool> checkedUsers,
}) {
  return Expanded(
    child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _getUserItem(context, cubit.users[index], index,
              checkedUsers: checkedUsers, onChanged: onChanged);
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSize.s6),
        itemCount: cubit.users.length),
  );
}

Widget _getUserItem(
  context,
  UserModel user,
  int index, {
  required Function(bool?, int) onChanged,
  required Map<int, bool> checkedUsers,
}) {
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
          value: checkedUsers[index] ?? false,
          onChanged: (value) {
            onChanged.call(value, index);
          },
        ),
      ],
    ),
  );
}
