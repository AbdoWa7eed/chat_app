abstract class ChatAppStates {}

class ChatAppInitialState extends ChatAppStates {}

class ChatAppLoadingStates extends ChatAppStates {}

class UploadImageLoadingState extends ChatAppLoadingStates {}

class UploadImageSuccessState extends ChatAppStates {}

class UploadImageErrorState extends ChatAppErrorStates {
  UploadImageErrorState(super.errorMessage);
}

class ChatAppErrorStates extends ChatAppStates {
  String errorMessage;
  ChatAppErrorStates(this.errorMessage);
}

class GetUserLoadingState extends ChatAppLoadingStates {}

class GetUserErrorState extends ChatAppErrorStates {
  GetUserErrorState(super.errorMessage);
}

class GetUserSuccessState extends ChatAppStates {}

class GetChatsSuccessState extends ChatAppStates {}

class GetChatsLoadingState extends ChatAppLoadingStates {}

class PickedImageState extends ChatAppStates {}

class GetChatsErrorState extends ChatAppErrorStates {
  GetChatsErrorState(super.errorMessage);
}

class SetUserStatusErrorState extends ChatAppErrorStates {
  SetUserStatusErrorState(super.errorMessage);
}

class SetUserStatusSuccessState extends ChatAppStates {}

class TabBarChangeState extends ChatAppStates {}

class CheckBoxState extends ChatAppStates {}

class CreateGroupLoadingState extends ChatAppStates {}

class CreateGroupSuccessState extends ChatAppStates {}

class CreateGroupErrorState extends ChatAppErrorStates {
  CreateGroupErrorState(super.errorMessage);
}

class GetAllUsersLoadingState extends ChatAppLoadingStates {}

class GetAllUsersSuccessState extends ChatAppStates {}

class GetAllUsersErrorState extends ChatAppErrorStates {
  GetAllUsersErrorState(super.errorMessage);
}

class UpdateUserDataLoadingState extends ChatAppLoadingStates {}

class UpdateUserDataSuccessState extends ChatAppStates {}

class UpdateUserDataErrorState extends ChatAppErrorStates {
  UpdateUserDataErrorState(super.errorMessage);
}

class UpdateGroupDataLoadingState extends ChatAppLoadingStates {}

class UpdateGroupDataSuccessState extends ChatAppStates {}

class UpdateGroupDataErrorState extends ChatAppErrorStates {
  UpdateGroupDataErrorState(super.errorMessage);
}

class ExitGroupLoadingState extends ChatAppLoadingStates {}

class ExitGroupSuccessState extends ChatAppStates {}

class ExitGroupErrorState extends ChatAppErrorStates {
  ExitGroupErrorState(super.errorMessage);
}

class SendNewGroupNotificationSuccessState extends ChatAppStates {}

class SendNewGroupNotificationErrorState extends ChatAppErrorStates {
  SendNewGroupNotificationErrorState(super.errorMessage);
}

class SetTokenSuccessState extends ChatAppStates {}

class SetTokenErrorState extends ChatAppErrorStates {
  SetTokenErrorState(super.errorMessage);
}
