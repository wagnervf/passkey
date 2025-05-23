import 'package:equatable/equatable.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

abstract class ImportRegistersCsvState extends Equatable {}


class ImportCsvInitial extends ImportRegistersCsvState {
  @override
  List<Object?> get props => [];
}

class ImportCsvLoading extends ImportRegistersCsvState {
 

@override
List<Object?> get props => [];
}

class ImportCsvLoaded extends ImportRegistersCsvState {

  @override
  List<RegisterModel> get props => [];
}


class ImportCsvError extends ImportRegistersCsvState {
  final String message;

  ImportCsvError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ImportCsvNull extends ImportRegistersCsvState {
  final String message;

  ImportCsvNull(this.message);
  
  @override
  List<Object?> get props => [message];
}