import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabBarScreens extends StatefulWidget {
  const TabBarScreens({super.key});

  @override
  State<TabBarScreens> createState() => _TabBarScreensState();
}

class _TabBarScreensState extends State<TabBarScreens> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = instance<ChatAppCubit>();
        return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (cubit.tabBarIndex == 0) {
                return _getSingleChatItemWidget(
                    cubit.chats[index], index, cubit);
              } else {
                return _getGroupChatItemWidget(
                    cubit.groups[index], index, cubit);
              }
            },
            separatorBuilder: (context, index) => const SizedBox(
                  height: AppSize.s25,
                ),
            itemCount: cubit.tabBarIndex == 0
                ? cubit.chats.length
                : cubit.groups.length);
      },
    );
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
        cubit.currentChatIndex = index;
        Navigator.of(context).pushNamed(Routes.chatRoute,
            arguments: {'isGroup': false, 'model': model});
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
        cubit.getGroupMembers(
          groupModel,
        );
        Navigator.of(context).pushNamed(Routes.chatRoute,
            arguments: {'isGroup': true, 'model': groupModel});
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
}
