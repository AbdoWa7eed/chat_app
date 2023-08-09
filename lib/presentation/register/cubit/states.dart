abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class UploadImageLoadingState extends RegisterStates {}

class UploadImageSuccessState extends RegisterStates {}

class UploadImageErrorState extends RegisterStates {
  String errorMessage;
  UploadImageErrorState(this.errorMessage);
}

class AddUserLoadingState extends RegisterStates {}

class AddUserSuccessState extends RegisterStates {}

class AddUserErrorState extends RegisterStates {
  String errorMessage;
  AddUserErrorState(this.errorMessage);
}

class PickedImageState extends RegisterStates {}
