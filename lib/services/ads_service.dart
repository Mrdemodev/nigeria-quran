import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'remote_config_service.dart';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static String get bannerAdUnitId       => RemoteConfigService.instance.bannerAdUnitId;
  static String get interstitialAdUnitId => RemoteConfigService.instance.interstitialAdUnitId;
  static String get rewarded1AdUnitId    => RemoteConfigService.instance.rewarded1AdUnitId;
  static String get rewarded2AdUnitId    => RemoteConfigService.instance.rewarded2AdUnitId;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  Future<void>? _initializationFuture;
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewarded1;
  RewardedInterstitialAd? _rewarded2;

  // Cooldown — never show an interstitial twice within 5 minutes
  DateTime? _lastInterstitialTime;
  static const _interstitialCooldown = Duration(minutes: 5);

  // ── Initialise ───────────────────────────────────────────
  /// Call fire-and-forget after runApp() — never awaited on the main path.
  Future<void> initialize() async {
    if (_initialized) return;
    if (_initializationFuture != null) return _initializationFuture!;
    _initializationFuture = _initialize();
    await _initializationFuture;
  }

  Future<void> _initialize() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired(
            (formError) {
              if (formError != null) {
                debugPrint('Consent form error: ${formError.message}');
              }
            },
          );

          if (!await ConsentInformation.instance.canRequestAds()) {
            completer.complete();
            return;
          }

          await MobileAds.instance.initialize();
          _initialized = true;
          debugPrint('AdMob initialised');
          Future.delayed(const Duration(seconds: 3), _loadInterstitial);
          Future.delayed(const Duration(seconds: 6), _loadRewarded1);
          Future.delayed(const Duration(seconds: 9), _loadRewarded2);
        } catch (e) {
          debugPrint('AdMob init error: $e');
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error) async {
        debugPrint('Consent info update error: ${error.message}');
        completer.complete();
      },
    );

    await completer.future;
  }

  // ── Interstitial ─────────────────────────────────────────
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial failed: $err');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial at a natural break point (e.g. leaving a surah).
  /// Returns true if the ad was shown. Respects the 5-min cooldown.
  bool showInterstitial() {
    if (!RemoteConfigService.instance.adsEnabled) return false;
    if (_interstitialAd == null) return false;
    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < _interstitialCooldown) {
      return false;
    }
    _lastInterstitialTime = now;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        Future.delayed(const Duration(seconds: 2), _loadInterstitial);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );
    _interstitialAd!.show();
    return true;
  }

  // ── Rewarded Interstitial 1 (download reward) ────────────
  void _loadRewarded1() {
    RewardedInterstitialAd.load(
      adUnitId: rewarded1AdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewarded1 = ad,
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded1 failed: $err');
          _rewarded1 = null;
        },
      ),
    );
  }

  /// Show rewarded interstitial 1. Calls [onRewarded] only if user earns reward.
  void showRewarded1(VoidCallback onRewarded) {
    if (_rewarded1 == null) { onRewarded(); return; }
    _rewarded1!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded1 = null;
        Future.delayed(const Duration(seconds: 2), _loadRewarded1);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded1 = null;
        onRewarded();
        _loadRewarded1();
      },
    );
    _rewarded1!.show(onUserEarnedReward: (_, __) => onRewarded());
  }

  // ── Rewarded Interstitial 2 (reciter unlock) ─────────────
  void _loadRewarded2() {
    RewardedInterstitialAd.load(
      adUnitId: rewarded2AdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewarded2 = ad,
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded2 failed: $err');
          _rewarded2 = null;
        },
      ),
    );
  }

  void showRewarded2(VoidCallback onRewarded) {
    if (_rewarded2 == null) { onRewarded(); return; }
    _rewarded2!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded2 = null;
        Future.delayed(const Duration(seconds: 2), _loadRewarded2);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded2 = null;
        onRewarded();
        _loadRewarded2();
      },
    );
    _rewarded2!.show(onUserEarnedReward: (_, __) => onRewarded());
  }
}
