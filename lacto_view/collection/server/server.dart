import 'dart:io';
import 'routes/user_routes.dart';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('🚀 Servidor rodando em http://localhost:8080');

  await for (HttpRequest request in server) {
    //handleRoutes(request);
  }
}
