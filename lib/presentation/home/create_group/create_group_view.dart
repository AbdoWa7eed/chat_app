import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/functions.dart';
import '../../common/widgets.dart';
import '../../cubit/app_cubit.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/values_manager.dart';

class CreateGroupWidget extends StatefulWidget {
  const CreateGroupWidget({super.key});

  @override
  State<CreateGroupWidget> createState() => _CreateGroupWidgetState();
}

class _CreateGroupWidgetState extends State<CreateGroupWidget> {
  final _groupNamecontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {
        _listenerStateValidation(state);
      },
      builder: (context, state) {
        var cubit = instance<ChatAppCubit>();
        return Form(
          key: _formKey,
          child: Dialog(
            backgroundColor: ColorManager.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _groupNamecontroller,
                  style: Theme.of(context).textTheme.displaySmall,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppStrings.thisFieldIsRequired.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppStrings.groupName.tr(),
                  ),
                ),
                const SizedBox(
                  height: AppSize.s20,
                ),
                Text(
                  AppStrings.selectMembers.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                getUsersListWidget(
                  cubit,
                  checkedUsers: cubit.checkedUsers,
                  onChanged: (value, index) {
                    cubit.addCheckedStateToMap(index, value);
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.s40,
                  child: ElevatedButton(
                    onPressed: () {
                      _createGroupValidation(cubit);
                    },
                    child: Text(AppStrings.createNewGroup.tr(),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  void _listenerStateValidation(ChatAppStates state) {
    if (state is CreateGroupLoadingState) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(AppPadding.p12),
            child: getDialogWidget(
              context,
              animatedImage: JsonAssets.loading,
              title: AppStrings.loading.tr(),
            ),
          );
        },
      );
    } else if (state is CreateGroupErrorState) {
      dismissDialog(context);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(AppPadding.p12),
            child: getDialogWidget(context,
                animatedImage: JsonAssets.error,
                title: state.errorMessage,
                isConfirmation: true),
          );
        },
      );
    } else if (state is CreateGroupSuccessState) {
      dismissDialog(context);
      Navigator.of(context).pop();
    }
  }

  void _createGroupValidation(ChatAppCubit cubit) {
    if (_formKey.currentState!.validate()) {
      if (cubit.checkedUsers.isEmpty) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(AppPadding.p12),
              child: getDialogWidget(context,
                  animatedImage: JsonAssets.error,
                  title: AppStrings.atLeast3Users.tr(),
                  isConfirmation: true),
            );
          },
        );
      } else {
        cubit.createNewGroup(_groupNamecontroller.text);
      }
    }
  }
}
