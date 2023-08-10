import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/chat/cubit/chat_cubit.dart';
import 'package:chat_app/presentation/chat/cubit/chat_states.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/common/loading_view.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ChatList extends StatefulWidget {
  final ScrollController scrollController;
  const ChatList({super.key, required this.scrollController});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InChatCubit, InChatStates>(
      builder: (context, state) {
        var cubit = instance<InChatCubit>();
        return _getChatWidget(context, cubit);
      },
      listener: (context, state) {},
    );
  }

  Widget _getChatWidget(context, InChatCubit cubit) {
    if (cubit.state is GetMessagesLoadingState) {
      return const LoadingScreen();
    } else if (cubit.messages.isEmpty) {
      return _getEmptyScreenWidget(context);
    } else{
      return _getListOfMessages(cubit.messages, cubit);
    }
  }

  Widget _getListOfMessages(List<MessageModel> messages, InChatCubit cubit) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: AppPadding.p14),
      child: ListView.separated(
          controller: widget.scrollController,
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
                if (cubit.isGroup) {
                  cubit.sendGroupMessage(message.message,
                      groupModel: cubit.groupModel);
                } else {
                  cubit.sendMessage(
                    message.message,
                    receiverModel: cubit.userModel,
                  );
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
          if (cubit.isGroup) ...[
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
}
