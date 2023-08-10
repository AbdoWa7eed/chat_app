import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/common/loading_view.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/home/create_group/create_group_view.dart';
import 'package:chat_app/presentation/home/menu/menu_items.dart';
import 'package:chat_app/presentation/home/settings/settings.dart';
import 'package:chat_app/presentation/home/tab_bar_screens.dart/tab_bar_screens.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../search_delegate/search_delegate.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      instance<ChatAppCubit>().setStatus(AppStrings.online.tr());
    } else {
      instance<ChatAppCubit>().setStatus(DateTime.now().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    _isTokenisValid();
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return getScreenWidget();
      },
    );
  }

  Widget getScreenWidget() {
    var cubit = instance<ChatAppCubit>();
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        titleSpacing: AppSize.s28,
        centerTitle: false,
        title: Text(
          AppStrings.appTitle.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          InkWell(
              onTap: () {
                showSearch(context: context, delegate: UsersSearch());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.s4),
                child: SvgPicture.asset(ImageAssets.searchIc),
              )),
          const SizedBox(
            width: AppSize.s14,
          ),
          PopupMenuButton<MenuItem>(
            color: ColorManager.backgroundColor,
            itemBuilder: (context) => MenuItems.items
                .map((item) => MenuItems.buildItem(item, context))
                .toList(),
            onSelected: _onMenuItemSelected,
            child: SvgPicture.asset(ImageAssets.moreIc),
          ),
          const SizedBox(
            width: AppSize.s28,
          ),
        ],
      ),
      body: DefaultTabController(
        length: AppConstants.tabBarLength,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p16, horizontal: AppPadding.p20),
              child: Container(
                height: AppSize.s50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.s50),
                    color: ColorManager.darkBackgroundColor),
                child: TabBar(
                  onTap: (value) {
                    cubit.setTabBarIndex(value);
                  },
                  indicator: BoxDecoration(
                      color: ColorManager.darkGray,
                      borderRadius: BorderRadius.circular(AppSize.s50)),
                  unselectedLabelColor: ColorManager.black,
                  tabs: [
                    Tab(text: AppStrings.messages.tr()),
                    Tab(text: AppStrings.groups.tr()),
                  ],
                ),
              ),
            ),
            _getContentWidget(cubit),
          ],
        ),
      ),
    );
  }

  Widget _getContentWidget(ChatAppCubit cubit) {
    if (cubit.state is ChatAppLoadingStates) {
      return const LoadingScreen();
    } else {
      if (cubit.tabBarIndex == 0) {
        return Expanded(
            child: cubit.chats.isNotEmpty && cubit.chattingUsers.isNotEmpty
                ? const TabBarScreens()
                : _getEmptyScreenWidget(cubit));
      } else {
        return Expanded(
            child: cubit.groups.isNotEmpty
                ? const TabBarScreens()
                : _getEmptyScreenWidget(cubit));
      }
    }
  }

  Widget _getEmptyScreenWidget(ChatAppCubit cubit) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(ImageAssets.noChatFound),
        Text(
          AppStrings.noChatFound.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (cubit.tabBarIndex == 1) ...[
          TextButton(
              onPressed: () {
                cubit.createUsersList();
                showDialog(
                  context: context,
                  builder: (context) => const CreateGroupWidget(),
                );
              },
              child: Text(
                AppStrings.createNewGroup.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: ColorManager.primary),
              )),
        ],
      ],
    );
  }

  _onMenuItemSelected(MenuItem value) {
    var cubit = instance<ChatAppCubit>();
    if (value == MenuItems.createGroupItem) {
      cubit.createUsersList();
      showDialog(
        context: context,
        builder: (context) => const CreateGroupWidget(),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const SettingsWidget(),
      );
    }
  }

  _isTokenisValid() async {
    var cubit = instance<ChatAppCubit>();
    var token = ModalRoute.of(context)?.settings.arguments as String?;
    if (token != null) {
      var currentToken = cubit.appPreferences.getDeviceToken();
      if (token != currentToken) {
        await instance<ChatAppCubit>().setDeviceToken(token);
        await cubit.appPreferences.setDeviceToken(token);
      }
    }
  }
}
