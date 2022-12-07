import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<InterstitialAd?> showAd() async {
  InterstitialAd? ad;
  print("sad");
  await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          ad = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ));
  return ad;
}
