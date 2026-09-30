import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';

/// Asset paths, named once so a filename cannot drift.
class OnboardingAssets {
  OnboardingAssets._();

  /// The same file the splash and welcome screens use — one piece of
  /// artwork, not three copies of it in the bundle.
  static const brandLogo = 'assets/images/splash/splash_brand_logo.png';

  static const teachingsHero =
      'assets/images/onboarding/onboarding_teachings_hero.webp';

  static const innerSpaceHero =
      'assets/images/onboarding/onboarding_innerspace_hero.webp';

  static const communityServiceHero =
      'assets/images/onboarding/onboarding_community_service_hero.webp';
}

/// One onboarding page.
///
/// [id] is a stable identifier, never the translated title: analytics and
/// tests that key off a title break the moment someone rewords it.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.id,
    required this.imageAsset,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String id;
  final String imageAsset;
  final String Function(AppLocalizations) eyebrow;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) description;
}

const onboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    id: 'teachings',
    imageAsset: OnboardingAssets.teachingsHero,
    eyebrow: _teachingsEyebrow,
    title: _teachingsTitle,
    description: _teachingsDescription,
  ),
  OnboardingPageData(
    id: 'inner_space',
    imageAsset: OnboardingAssets.innerSpaceHero,
    eyebrow: _innerSpaceEyebrow,
    title: _innerSpaceTitle,
    description: _innerSpaceDescription,
  ),
  OnboardingPageData(
    id: 'community_service',
    imageAsset: OnboardingAssets.communityServiceHero,
    eyebrow: _communityEyebrow,
    title: _communityTitle,
    description: _communityDescription,
  ),
];

// Top-level functions rather than closures, so the page list stays const.
String _teachingsEyebrow(AppLocalizations t) => t.onboardingTeachingsEyebrow;
String _teachingsTitle(AppLocalizations t) => t.onboardingTeachingsTitle;
String _teachingsDescription(AppLocalizations t) =>
    t.onboardingTeachingsDescription;

String _innerSpaceEyebrow(AppLocalizations t) =>
    t.onboardingInnerSpaceEyebrow;
String _innerSpaceTitle(AppLocalizations t) => t.onboardingInnerSpaceTitle;
String _innerSpaceDescription(AppLocalizations t) =>
    t.onboardingInnerSpaceDescription;

String _communityEyebrow(AppLocalizations t) => t.onboardingCommunityEyebrow;
String _communityTitle(AppLocalizations t) => t.onboardingCommunityTitle;
String _communityDescription(AppLocalizations t) =>
    t.onboardingCommunityDescription;
