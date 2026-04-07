import 'package:cloud_user/features/home/data/hero_section_model.dart';

enum LogoDeviceType { phone, tablet, website }

LogoDeviceType logoDeviceTypeForWidth(double width) {
  if (width < 700) return LogoDeviceType.phone;
  if (width < 1100) return LogoDeviceType.tablet;
  return LogoDeviceType.website;
}

String logoDeviceTypeKey(LogoDeviceType type) {
  switch (type) {
    case LogoDeviceType.phone:
      return 'phone';
    case LogoDeviceType.tablet:
      return 'tablet';
    case LogoDeviceType.website:
      return 'website';
  }
}

String resolveHeroLogoForWidth(HeroSectionModel? hero, double width) {
  return resolveHeroLogoForDevice(
    hero: hero,
    deviceType: logoDeviceTypeForWidth(width),
  );
}

String resolveHeroLogoForDevice({
  required HeroSectionModel? hero,
  required LogoDeviceType deviceType,
}) {
  if (hero == null) return '';
  final logos = hero.logoByDevice;
  final selected = (logos[logoDeviceTypeKey(deviceType)] ?? '').trim();
  if (selected.isNotEmpty) return selected;

  final websiteLogo = (logos['website'] ?? '').trim();
  if (websiteLogo.isNotEmpty) return websiteLogo;

  final tabletLogo = (logos['tablet'] ?? '').trim();
  final phoneLogo = (logos['phone'] ?? '').trim();
  if (deviceType == LogoDeviceType.phone && tabletLogo.isNotEmpty) {
    return tabletLogo;
  }
  if (deviceType == LogoDeviceType.website && tabletLogo.isNotEmpty) {
    return tabletLogo;
  }
  if (phoneLogo.isNotEmpty) return phoneLogo;
  if (tabletLogo.isNotEmpty) return tabletLogo;

  return hero.logoUrl.trim();
}

Map<String, String> mergeLogoByDeviceMaps(
  List<Map<String, String>?> maps,
) {
  final merged = <String, String>{};
  for (final map in maps) {
    if (map == null) continue;
    for (final entry in map.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        merged[entry.key] = value;
      }
    }
  }
  return merged;
}
