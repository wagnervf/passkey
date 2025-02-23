

abstract class BackupRestoreState {}

class BackupRestoreStateInitialState extends BackupRestoreState {}

class BackupRestoreStateLoadingState extends BackupRestoreState {}

class BackupRestoreStateSuccessState extends BackupRestoreState {
  

 // BackupRestoreStateSuccessState();
}
class BackupRestoreStateUnauthenticatedState extends BackupRestoreState {}

class BackupRestoreStateErrorState extends BackupRestoreState {
  final String message;

  BackupRestoreStateErrorState(this.message);
}


