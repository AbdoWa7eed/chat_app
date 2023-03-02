
abstract class PhoneAuthStates{}

class PhoneAuthInitialSates extends PhoneAuthStates{}

class SendCodeLoadingState extends PhoneAuthStates{}

class SendCodeErrorState extends PhoneAuthStates{
  String errorMessage;
  SendCodeErrorState(this.errorMessage);
}

class SendCodeSuccessState extends PhoneAuthStates{}

class VerificationStates extends PhoneAuthStates{}

class VerifyCodeLoadingState extends VerificationStates{}

class VerifyCodeErrorState extends VerificationStates{
  String errorMessage;
  VerifyCodeErrorState(this.errorMessage);
}

class VerifyCodeSuccessState extends VerificationStates{}