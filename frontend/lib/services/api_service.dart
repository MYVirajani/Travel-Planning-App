import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/trip_plan_event.dart';

class ApiService {
  Stream<TripPlanEvent> planTrip({
    required String message,
    List<Map<String, dynamic>>? previousItinerary,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse(AppConstants.planTripEndpoint),
    );
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'message': message,
      if (previousItinerary != null) 'previous_itinerary': previousItinerary,
    });

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw HttpException(
          'Server returned ${streamedResponse.statusCode}',
        );
      }

      String? pendingEventName;
      final buffer = StringBuffer();

      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        var content = buffer.toString();

        while (content.contains('\n\n')) {
          final splitIndex = content.indexOf('\n\n');
          final rawBlock = content.substring(0, splitIndex);
          content = content.substring(splitIndex + 2);

          for (final line in rawBlock.split('\n')) {
            if (line.startsWith('event:')) {
              pendingEventName = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              final dataJson = line.substring(5).trim();
              if (pendingEventName != null) {
                yield TripPlanEvent.fromRaw(pendingEventName, dataJson);
                pendingEventName = null;
              }
            }
          }
        }

        buffer
          ..clear()
          ..write(content);
      }
    } finally {
      client.close();
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}