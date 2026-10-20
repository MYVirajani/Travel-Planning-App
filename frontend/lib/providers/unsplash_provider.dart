import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unsplash_service.dart';

final unsplashServiceProvider = Provider((ref) => UnsplashService());


final destinationImageProvider =
FutureProvider.family<String?, String>((ref, query) async {
  final service = ref.read(unsplashServiceProvider);
  return service.fetchImageUrl(query);
});