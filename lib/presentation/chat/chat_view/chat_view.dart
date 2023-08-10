import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/chat/chat_view/chat_list.dart';
import 'package:chat_app/presentation/chat/cubit/chat_cubit.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat_states.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var cubit = instance<InChatCubit>();
    _setModel(cubit);
    return BlocProvider<InChatCubit>.value(
      value: _initCubit(cubit),
      child: BlocConsumer<InChatCubit, InChatStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return _getContentWidget(context, cubit);
        },
      ),
    );
  }

  Widget _getContentWidget(BuildContext context, InChatCubit cubit) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        elevation: AppSize.s2,
        shadowColor: ColorManager.lightBlack,
        centerTitle: false,
        titleSpacing: AppSize.s10,
        title: InkWell(
          onTap: () {
            if (cubit.isGroup) {
              Navigator.of(context).pushNamed(Routes.groupInfoRoute,
                  arguments: cubit.groupModel);
            } else {
              Navigator.of(context)
                  .pushNamed(Routes.userInfoRoute, arguments: cubit.userModel);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: AppSize.s20,
                backgroundImage: NetworkImage(
                  cubit.isGroup
                      ? cubit.groupModel.groupImage
                      : cubit.userModel.imageLink,
                ),
                backgroundColor: ColorManager.darkGray,
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
                      cubit.isGroup
                          ? cubit.groupModel.groupName
                          : cubit.userModel.nickName,
                      maxLines: AppConstants.minLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!cubit.isGroup) ...[
                      Text(
                        _getStatues(cubit.userModel.status),
                        overflow: TextOverflow.ellipsis,
                        maxLines: AppConstants.minLines,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        leading: appBarLeading(onPressed: () {
          closeChat(cubit);
        }),
        automaticallyImplyLeading: false,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return false;
        },
        child: Column(
          children: [
            ChatList(scrollController: _scrollController),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p8,
                          vertical: AppPadding.p14,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          controller: _messageController,
                          minLines: AppConstants.minLines,
                          maxLines: AppConstants.messageMaxLines,
                          style: Theme.of(context).textTheme.displaySmall,
                          decoration: InputDecoration(
                            hintText: AppStrings.typeHere.tr(),
                          ),
                        ))),
                SizedBox(
                  height: AppSize.s75,
                  child: IconButton(
                    onPressed: () {
                      if (_messageController.text.isNotEmpty &&
                          _messageController.text.trim().isNotEmpty) {
                        if (cubit.isGroup) {
                          cubit.sendGroupMessage(
                            validateText(_messageController.text),
                            groupModel: cubit.groupModel,
                          );
                        } else {
                          cubit.sendMessage(
                            validateText(_messageController.text),
                            receiverModel: cubit.userModel,
                          );
                        }
                        _messageController.clear();
                        _animateToTheEnd();
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getStatues(String? status) {
    if (status == null) {
      return "${AppStrings.lastSeen.tr()}${AppStrings.undetermined.tr()}";
    } else {
      if (status == AppStrings.onlineEn || status == AppStrings.onlineAr) {
        return AppStrings.online.tr();
      } else {
        return "${AppStrings.lastSeen.tr()}${validateTime(status)}";
      }
    }
  }

  void _setModel(InChatCubit cubit) {
    var data = ModalRoute.of(context)?.settings.arguments as Map;
    cubit.isGroup = data['isGroup'];
    if (!cubit.isGroup) {
      cubit.userModel = data['model'];
    } else {
      cubit.groupModel = data['model'];
    }
  }

  void _animateToTheEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        0.0,
      );
    }
  }

  InChatCubit _initCubit(InChatCubit cubit) {
    cubit.messages.clear();
    if (cubit.isGroup) {
      return cubit
        ..getGroupMessages(cubit.groupModel.uid)
        ..setGroupUnreadMessages(cubit.groupModel);
    } else {
      return cubit..getMessages(cubit.userModel);
    }
  }

  closeChat(InChatCubit cubit) {
    if (cubit.isGroup) {
      cubit.chatAppCubit.groupMembers.clear();
      cubit.setGroupUnreadMessages(cubit.groupModel);
    } else {
      cubit.setUnreadMessages(cubit.userModel.uid);
    }
    cubit.chatAppCubit.currentChatIndex = null;
    Navigator.of(context).pop();
  }
}
