import 'package:dart_frog/dart_frog.dart';

Middleware loggingMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      print('Request: ${request.method} ${request.url}');
      final response = await handler(context);
      print('Response: ${response.statusCode}');
      return response;
    };
  };
}

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final token = context.request.headers['Authorization'];
      if (token == null || !isValidToken(token)) {
        return Response.forbidden('Unauthorized');
      }
      return await handler(context);
    };
  };
}

bool isValidToken(String token) {
  // Implement your token validation logic here
  return token == 'valid_token';
}