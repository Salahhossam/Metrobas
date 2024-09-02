import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thirddraft/darkcubit/states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(IntialAppState());

  static AppCubit get(context) {
    return BlocProvider.of(context);
  }

  List<Map<String, dynamic>?>? singlePath;
  List<Map<String, dynamic>?>? listSaveJourneys;
  Map<String, dynamic>? userInfo;
  Map<String, dynamic>? saveJourneys;
  List<Map<String, dynamic>?>? saveMessage;

  // Future<void> getUserData() async {
  //   if (FirebaseAuth.instance.currentUser != null) {
  //     emit(GetUserDataLoading());
  //     await firestore
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .get()
  //         .then((value) {
  //       userModel = UserModel.fromJson(value.data()!);
  //       emit(GetUserDataSucsess());
  //     }).catchError((error) {
  //       //print("Here Error ${error.toString()}");
  //       emit(GetUserDataError(error.toString()));
  //     });
  //   }
  // }

  userInfoData(data) {
    userInfo = data;
    emit(GetUserInfoDataSucsess());
  }

  singlePathData(data) {
    singlePath = data;

    emit(GetSinglePathDataSucsess());
  }

  // userInfoData(data) {
  //   userInfo = data;

  //   emit(GetUserInfoDataSucsess());
  // }
  saveJourneysData(data) {
    saveJourneys = data;

    emit(GetSaveJourneyDataSucsess());
  }
  listSaveMessageData(data) {
    saveMessage = data;

    emit(GetSaveMessageDataSucsess());
  }

  listSaveJourneysData(data) {
    listSaveJourneys = data;

    emit(GetlistSaveJourneysDataSucsess());
  }

  void updateUserInfo(Map<String, dynamic> newUserInfo) {
    userInfo = newUserInfo;
    emit(UserInfoUpdatedState());
  }
  
}
