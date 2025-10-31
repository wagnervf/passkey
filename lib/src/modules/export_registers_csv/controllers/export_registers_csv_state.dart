import 'package:equatable/equatable.dart';

abstract class ExportRegistersCsvState extends Equatable {}


class ExportCsvInitial extends ExportRegistersCsvState {
  @override
  List<Object?> get props => [];
}

class ExportCsvLoading extends ExportRegistersCsvState {
 

@override
List<Object?> get props => [];
}

class ExportCsvLoaded extends ExportRegistersCsvState {
  final String message;

  ExportCsvLoaded(this.message);
  
  @override
  List<Object?> get props => [message];
}


class ExportCsvError extends ExportRegistersCsvState {
  final String message;

  ExportCsvError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ExportCsvNull extends ExportRegistersCsvState {
  final String message;

  ExportCsvNull(this.message);
  
  @override
  List<Object?> get props => [message];
}