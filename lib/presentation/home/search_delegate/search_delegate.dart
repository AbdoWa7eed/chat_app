import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../../../app/di.dart';
import '../../../domain/models/models.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/constants_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class UsersSearch extends SearchDelegate {
  @override
  Widget buildResults(BuildContext context) {
    instance<ChatAppCubit>().getUserData(query);
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = instance<ChatAppCubit>();
        cubit.currentChatIndex = null;
        if (cubit.userModel != null && state is GetUserSuccessState) {
          return _getChatSearchedItemWidget(context, cubit.userModel!);
        } else if (state is GetUserErrorState) {
          return _getEmptyScreenWidget(context, message: state.errorMessage);
        } else {
          return _getLoadingScreen(context);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // todo make list of userModel called suggestion which will be displayed to user
    // todo map over the list and check if the word is exists
    return Container(color: ColorManager.backgroundColor);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: ColorManager.backgroundColor,
              centerTitle: false,
              titleSpacing: AppSize.s1,
              elevation: AppSize.s4,
            ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: AppSize.s1, color: ColorManager.backgroundColor)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: AppSize.s1, color: ColorManager.backgroundColor)),
        ));
  }

  @override
  String? get searchFieldLabel => AppStrings.searchByUsername.tr();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios,
          size: AppSize.s20, color: ColorManager.black),
      onPressed: () => close(context, null),
    );
  }

  Widget _getEmptyScreenWidget(BuildContext context, {String? message}) {
    return Container(
      color: ColorManager.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(ImageAssets.noChatFound),
            Text(
              message ?? AppStrings.nothingToShow.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(
              height: AppSize.s30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getChatSearchedItemWidget(BuildContext context, UserModel userModel) {
    return Container(
      alignment: AlignmentDirectional.topStart,
      color: ColorManager.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              close(context, userModel);
              Navigator.of(context).pushNamed(Routes.chatRoute,
                  arguments: {'isGroup': false, 'model': userModel});
            },
            child: SizedBox(
              height: AppSize.s60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: AppSize.s25,
                      backgroundImage: NetworkImage(userModel.imageLink),
                      backgroundColor: ColorManager.darkGray,
                    ),
                    const SizedBox(
                      width: AppSize.s10,
                    ),
                    Text(
                      userModel.nickName,
                      maxLines: AppConstants.minLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLoadingScreen(context) {
    return Container(
      color: ColorManager.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(JsonAssets.loading),
            const SizedBox(
              height: AppSize.s20,
            ),
            Text(AppStrings.loading.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
