import 'package:cloud_user/core/network/api_client.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hero_provider.g.dart';

@riverpod
Future<HeroSectionModel?> heroSection(HeroSectionRef ref) async {
  final dio = ref.watch(apiClientProvider);

  try {
    final response = await dio.get('/hero');

    if (response.statusCode == 200) {
      return HeroSectionModel.fromJson(response.data);
    }
    return null;
  } catch (e) {
    return null; // Return null on error, UI should handle fallback
  }
}
