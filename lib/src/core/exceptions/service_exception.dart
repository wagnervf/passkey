class ServiceException implements Exception {
  ServiceException({this.message = ''});
  final String message;
}
