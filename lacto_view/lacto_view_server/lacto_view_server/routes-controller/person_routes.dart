import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:firedart/firedart.dart';
import '../service/person_service.dart';

final firestore = Firestore.initialize('seu-project-id');
final personService = PersonService(firestore);

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  try {
    final role = context.request.uri.queryParameters['role'];
    final persons = await personService.findPersons(role: role);
    final jsonResponse = persons.map((p) => p.toMap()).toList();
    return Response.json(body: jsonResponse);
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 400);
  }
}
