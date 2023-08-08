import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/home/create_group/create_group_view.dart';
import 'package:chat_app/presentation/home/menu/menu_items.dart';
import 'package:chat_app/presentation/home/settings/settings.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import '../../../domain/models/models.dart';
import '../../common/wigets.dart';
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
    if (cubit.state is ChatAppLoadingStates && !cubit.isGroup) {
      return _getLoadingScreen();
    } else {
      if (cubit.tabBarIndex == 0) {
        return Expanded(
            child: cubit.chats.isNotEmpty && cubit.chattingUsers.isNotEmpty
                ? _getChatsListWidget(cubit)
                : _getEmptyScreenWidget(cubit));
      } else {
        return Expanded(
            child: cubit.groups.isNotEmpty
                ? _getChatsListWidget(cubit)
                : _getEmptyScreenWidget(cubit));
      }
    }
  }

  Widget _getChatsListWidget(ChatAppCubit cubit) {
    return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (cubit.tabBarIndex == 0) {
            return _getSingleChatItemWidget(cubit.chats[index], index, cubit);
          } else {
            return _getGroupChatItemWidget(cubit.groups[index], index, cubit);
          }
        },
        separatorBuilder: (context, index) => const SizedBox(
              height: AppSize.s25,
            ),
        itemCount:
            cubit.tabBarIndex == 0 ? cubit.chats.length : cubit.groups.length);
  }

  Widget _getSingleChatItemWidget(
      ChatModel chat, int index, ChatAppCubit cubit) {
    final UserModel model;
    if (chat.receiverUser == UID) {
      model = cubit.chattingUsers[chat.senderUser]!;
    } else {
      model = cubit.chattingUsers[chat.receiverUser]!;
    }
    return InkWell(
      onTap: () async {
        cubit.isGroup = false;
        cubit.currentChatIndex = index;
        Navigator.of(context).pushNamed(Routes.chatRoute, arguments: model);
      },
      child: SizedBox(
        height: AppSize.s60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  CircleAvatar(
                    radius: AppSize.s25,
                    backgroundImage: NetworkImage(model.imageLink),
                    backgroundColor: ColorManager.darkGray,
                  ),
                  // if (model.status == AppStrings.online) ...[
                  //   CircleAvatar(
                  //     radius: AppSize.s6,
                  //     backgroundColor: ColorManager.green,
                  //   )
                  // ]
                ],
              ),
              const SizedBox(
                width: AppSize.s10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      model.nickName,
                      maxLines: AppConstants.minLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      chat.lastMessage,
                      overflow: TextOverflow.ellipsis,
                      maxLines: AppConstants.minLines,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppSize.s6,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //12/2/2023
                  Text(
                    validateTime(chat.lastMessageTime),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (chat.unreadMessages != 0) ...[
                    CircleAvatar(
                      radius: AppSize.s10,
                      child: Text("${chat.unreadMessages}",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: ColorManager.white)),
                    )
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGroupChatItemWidget(
      GroupChatModel groupModel, int index, ChatAppCubit cubit) {
    return InkWell(
      onTap: () {
        cubit.isGroup = true;
        cubit.getGroupMembers(groupModel).then((value) {
          Navigator.of(context)
              .pushNamed(Routes.chatRoute, arguments: groupModel);
        });
      },
      child: SizedBox(
        height: AppSize.s60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  CircleAvatar(
                    radius: AppSize.s25,
                    backgroundImage: NetworkImage(groupModel.groupImage),
                    backgroundColor: ColorManager.darkGray,
                  ),
                ],
              ),
              const SizedBox(
                width: AppSize.s10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      groupModel.groupName,
                      maxLines: AppConstants.minLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      groupModel.lastMessage,
                      overflow: TextOverflow.ellipsis,
                      maxLines: AppConstants.minLines,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppSize.s6,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //12/2/2023
                  Text(
                    groupModel.lastMessageTime.isNotEmpty
                        ? validateTime(groupModel.lastMessageTime)
                        : groupModel.lastMessageTime,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (groupModel.groupMembers[appUserModel!.uid] != 0) ...[
                    CircleAvatar(
                      radius: AppSize.s10,
                      child: Text(
                          "${groupModel.groupMembers[appUserModel!.uid]}",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: ColorManager.white)),
                    )
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
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

  Widget _getLoadingScreen() {
    return Expanded(
      child: Container(
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
      ),
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
    var token = ModalRoute.of(context)?.settings.arguments as String?;
    if (token != null) {
      var currentToken = instance<AppPreferences>().getDeviceToken();
      if (token != currentToken) {
        await instance<ChatAppCubit>().setDeviceToken(token);
        await instance<AppPreferences>().setDeviceToken(token);
      }
    }
  }
}
