import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/chat/cubit/chat_cubit.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../cubit/chat_states.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  late UserModel _userModel;
  late GroupChatModel _groupModel;
  late bool _isGroup = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _setModel(instance<ChatAppCubit>());
    var cubit = instance<InChatCubit>();
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
            if (_isGroup) {
              Navigator.of(context)
                  .pushNamed(Routes.groupInfoRoute, arguments: _groupModel);
            } else {
              Navigator.of(context)
                  .pushNamed(Routes.userInfoRoute, arguments: _userModel);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: AppSize.s20,
                backgroundImage: NetworkImage(
                  _isGroup ? _groupModel.groupImage : _userModel.imageLink,
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
                      _isGroup ? _groupModel.groupName : _userModel.nickName,
                      maxLines: AppConstants.minLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!_isGroup) ...[
                      Text(
                        _getStatues(cubit.userStatus),
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
            _getChatWidget(context, cubit),
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
                        if (_isGroup) {
                          cubit.sendGroupMessage(
                              validateText(_messageController.text),
                              groupModel: _groupModel);
                        } else {
                          cubit.sendMessage(
                              validateText(_messageController.text),
                              receiverModel: _userModel);
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

  Widget _getChatWidget(context, InChatCubit cubit) {
    if (cubit.messages.isNotEmpty) {
      return _getListOfMessages(cubit.messages, cubit);
    } else if (cubit.state is GetMessagesLoadingState) {
      return _getLoadingScreen(context);
    } else {
      return _getEmptyScreenWidget(context);
    }
  }

  Widget _getListOfMessages(List<MessageModel> messages, InChatCubit cubit) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: AppPadding.p14),
      child: ListView.separated(
          controller: _scrollController,
          reverse: true,
          itemBuilder: (context, index) {
            if (messages[index].senderUID == UID) {
              return _getSentMessageWidget(messages[index], cubit);
            } else {
              return _getReceivedMessageWidget(messages[index], cubit: cubit);
            }
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSize.s15),
          itemCount: messages.length),
    ));
  }

  Widget _getSentMessageWidget(MessageModel message, InChatCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p28,
      ),
      child: InkWell(
        onTap: message.isError
            ? () {
                cubit.messages.removeAt(0);
                if (_isGroup) {
                  cubit.sendGroupMessage(message.message,
                      groupModel: _groupModel);
                } else {
                  cubit.sendMessage(message.message, receiverModel: _userModel);
                }
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppPadding.p14, horizontal: AppPadding.p14),
                decoration: BoxDecoration(
                    color: ColorManager.sentMessageColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSize.s8),
                      bottomLeft: Radius.circular(AppSize.s8),
                      bottomRight: Radius.circular(AppSize.s8),
                    )),
                child: Text(validateText(message.message),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: ColorManager.white)),
              ),
            ),
            if (!message.isError) ...[
              const SizedBox(height: AppSize.s6),
              Text(
                validateTime(message.dateTime),
                style: Theme.of(context).textTheme.labelSmall,
              )
            ],
            if (message.isError) ...[
              const SizedBox(height: AppSize.s6),
              Text(
                AppStrings.resendMessage.tr(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: ColorManager.error),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _getReceivedMessageWidget(MessageModel message,
      {required InChatCubit cubit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isGroup) ...[
            Text(
              cubit.chatAppCubit.groupMembers[message.senderUID]?.username ??
                  message.senderName,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: AppSize.s6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p14, horizontal: AppPadding.p14),
              decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppSize.s8),
                    bottomLeft: Radius.circular(AppSize.s8),
                    bottomRight: Radius.circular(AppSize.s8),
                  )),
              child: Text(message.message,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: ColorManager.darkGray)),
            ),
          ),
          const SizedBox(height: AppSize.s6),
          Text(
            validateTime(message.dateTime),
            style: Theme.of(context).textTheme.labelSmall,
          )
        ],
      ),
    );
  }

  Widget _getLoadingScreen(context) {
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

  Widget _getEmptyScreenWidget(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(ImageAssets.noChatFound),
          Text(
            AppStrings.thereNoMessage.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  String validateText(String message) {
    return message
        .split(RegExp(r'(?:\r?\n|\r)'))
        .where((s) => s.trim().isNotEmpty)
        .join('\n');
  }

  void _animateToTheEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        0.0,
      );
    }
  }

  void _setModel(ChatAppCubit cubit) {
    if (!cubit.isGroup) {
      _userModel = ModalRoute.of(context)?.settings.arguments as UserModel;
    } else {
      _groupModel =
          ModalRoute.of(context)?.settings.arguments as GroupChatModel;
    }
  }

  _isGroupChat(ChatAppCubit cubit) {
    _isGroup = cubit.isGroup;
  }

  InChatCubit _initCubit(InChatCubit cubit) {
    _isGroupChat(cubit.chatAppCubit);
    cubit.messages.clear();
    if (_isGroup) {
      return cubit
        ..getGroupMessages(_groupModel.uid)
        ..setGroupUnreadMessages(_groupModel);
    } else {
      return cubit
        ..getMessages(_userModel)
        ..setUnreadMessages(_userModel.uid);
    }
  }

  closeChat(InChatCubit cubit) {
    if (_isGroup) {
      cubit.chatAppCubit.isGroup = false;
      cubit.chatAppCubit.groupMembers.clear();
      cubit.setGroupUnreadMessages(_groupModel);
    } else {
      cubit.setUnreadMessages(_userModel.uid);
    }
    cubit.chatAppCubit.currentChatIndex = null;
    Navigator.of(context).pop();
  }

}
