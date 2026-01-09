import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/firebase_home_repository.dart';
import 'package:cloud_user/features/home/data/stats_model.dart';
import 'package:cloud_user/features/home/data/testimonial_model.dart';
import 'package:cloud_user/features/home/data/why_choose_us_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_content_providers.g.dart';

@riverpod
Future<AboutUsModel?> aboutUs(AboutUsRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getAboutUs();
}

@riverpod
Future<StatsModel?> stats(StatsRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getStats();
}

@riverpod
Future<List<TestimonialModel>> testimonials(TestimonialsRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getTestimonials();
}

@riverpod
Future<List<WhyChooseUsModel>> whyChooseUs(WhyChooseUsRef ref) async {
  final data = await ref.watch(firebaseHomeRepositoryProvider).getWhyChooseUs();
  if (data.isEmpty) {
    return [
      WhyChooseUsModel(
        id: '1',
        title: 'Premium Quality',
        description: 'We use the finest detergents and specialized care.',
        iconUrl: '',
        isActive: true,
      ),
      WhyChooseUsModel(
        id: '2',
        title: 'Express Delivery',
        description: 'Get your clothes back clean within 24 hours.',
        iconUrl: '',
        isActive: true,
      ),
      WhyChooseUsModel(
        id: '3',
        title: 'Expert Handling',
        description:
            'Our staff is trained to handle delicate fabrics with care.',
        iconUrl: '',
        isActive: true,
      ),
    ];
  }
  return data;
}
