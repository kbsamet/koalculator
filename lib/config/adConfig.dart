import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<InterstitialAd?> showAd() async {
  InterstitialAd? _ad;
  await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          _ad = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ));
  return _ad;
}
