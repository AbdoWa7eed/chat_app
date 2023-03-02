
abstract class InChatStates{}


class InChatInitialState extends InChatStates {}

abstract class InChatErrorState extends InChatStates {
String errorMessage;
InChatErrorState(this.errorMessage);
}

class GetMessagesSuccessState extends InChatStates {}

class GetMessagesLoadingState extends InChatStates {}

class GetMessagesErrorState extends InChatErrorState{
  GetMessagesErrorState(super.errorMessage);
}

class SendMessageSuccessState  extends InChatStates {}

class SendMessagesLoadingState  extends InChatStates {}

class SendMessagesErrorState  extends InChatErrorState {
  SendMessagesErrorState(super.errorMessage);
}

class GetUserStatusSuccessState  extends InChatStates {}

class GetUserStatusErrorState  extends InChatErrorState {
  GetUserStatusErrorState(super.errorMessage);
}

class SendNotificationSuccessState  extends InChatStates {}

class SendNotificationErrorState  extends InChatErrorState {
   SendNotificationErrorState(super.errorMessage);
}

class SetUnreadMessagesSuccessState extends InChatStates {}

class SetUnreadMessagesErrorState  extends InChatStates {
  String errorMessage;
  SetUnreadMessagesErrorState(this.errorMessage);
}
