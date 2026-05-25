import '../constants/image_assets.dart';

String? getTransactionLogoAsset(String title) {
  final name = title.toLowerCase();
  if (name.contains('upwork')) {
    return ImageAssets.logoUpwork;
  }
  if (name.contains('transfer')) {
    return ImageAssets.profileIcon;
  }
  if (name.contains('paypal')) {
    return ImageAssets.logoPaypal;
  }
  if (name.contains('youtube')) {
    return ImageAssets.logoYoutube;
  }
  if (name.contains('starbucks')) {
    return ImageAssets.logoStarbucks;
  }
  return null;
}

String? getBillLogoAsset(String name) {
  final cleanName = name.toLowerCase();
  if (cleanName.contains('youtube')) return ImageAssets.billYoutube;
  if (cleanName.contains('electricity')) return ImageAssets.billElectricity;
  if (cleanName.contains('rent') || cleanName.contains('house')) return ImageAssets.billHouseRent;
  if (cleanName.contains('spotify')) return ImageAssets.billSpotify;
  return null;
}

double getLogoPadding(String assetName) {
  return (assetName == ImageAssets.logoUpwork || assetName == ImageAssets.profileIcon) ? 6 : 10;
}
