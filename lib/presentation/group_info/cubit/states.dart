abstract class GroupInfoStates {}

class GroupInfoInitialState extends GroupInfoStates {}

abstract class GroupInfoErrorStates extends GroupInfoStates {
  String errorMessage;
  GroupInfoErrorStates(this.errorMessage);
}

class UploadImageLoadingState extends GroupInfoStates {}

class UploadImageErrorState extends GroupInfoErrorStates {
  UploadImageErrorState(super.error);
}

class UploadImageSuccessState extends GroupInfoStates {}

class UpdateGroupDataLoadingState extends GroupInfoStates {}

class UpdateGroupDataErrorState extends GroupInfoErrorStates {
  UpdateGroupDataErrorState(super.errorMessage);
}

class UpdateGroupDataSuccessState extends GroupInfoStates {}

class ExitGroupErrorState extends GroupInfoErrorStates {
  ExitGroupErrorState(super.error);
}

class ExitGroupSuccessState extends GroupInfoStates {}

class PickedImageState extends GroupInfoStates {}

class CheckBoxState extends GroupInfoStates {}

