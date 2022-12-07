import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<InterstitialAd?> showAd() async {
  InterstitialAd? ad_;
  print("sad");
  await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print(ad);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
            },
          );
          // Keep a reference to the ad so you can show it later.
          ad_ = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ));
  return ad_;
}

BannerAd showBannerAd() {
  //show banner ad
  BannerAd bannerAd = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/2934735716',
    request: const AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        print('Ad failed to load: $error');
      },
      onAdOpened: (Ad ad) => print('Ad opened.'),
      onAdClosed: (Ad ad) => print('Ad closed.'),
    ),
  );

  return bannerAd;
}
