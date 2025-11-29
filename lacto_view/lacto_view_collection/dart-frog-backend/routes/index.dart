import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Define your route handling logic here
  return Response.json({'message': 'Welcome to the Dart Frog backend!'});
}