import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import '../constants/app_constants.dart';

class AdService {
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // TODO: Replace with actual ad unit IDs in production
  static const String _bannerAdUnitId = _testBannerAdUnitId;
  static const String _interstitialAdUnitId = _testInterstitialAdUnitId;
  
  final StreamController<AdEvent> _adEventController = StreamController<AdEvent>.broadcast();
  
  BannerAd? _currentBannerAd;
  InterstitialAd? _currentInterstitialAd;
  bool _isInitialized = false;
  int _adsShownInCurrentSync = 0;
  DateTime? _lastSyncTime;
  bool _isAdFreeActive = false;
  DateTime? _adFreeExpiryTime;

  // Streams
  Stream<AdEvent> get adEventStream => _adEventController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAdFreeActive => _isAdFreeActive && 
      (_adFreeExpiryTime?.isAfter(DateTime.now()) ?? false);
  BannerAd? get currentBannerAd => _currentBannerAd;

  Future<Result<void>> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _adEventController.add(AdEvent.initialized);
      return const Success(null);
    } catch (e) {
      return Error(AdLoadFailure(message: 'Failed to initialize ads: $e'));
    }
  }

  Future<Result<BannerAd>> loadBannerAd({AdSize? adSize}) async {
    if (!_isInitialized) {
      return const Error(AdLoadFailure(message: 'Ad service not initialized'));
    }

    if (isAdFreeActive) {
      return const Error(AdLoadFailure(message: 'Ad-free mode is active'));
    }

    try {
      final completer = Completer<Result<BannerAd>>();
      
      final bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: adSize ?? AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _currentBannerAd = ad as BannerAd;
            _adEventController.add(AdEvent.bannerLoaded);
            completer.complete(Success(ad as BannerAd));
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _adEventController.add(AdEvent.bannerFailedToLoad);
            completer.complete(Error(AdLoadFailure(
              message: 'Failed to load banner ad: ${error.message}',
              code: error.code,
            )));
          },
          onAdOpened: (ad) {
            _adEventController.add(AdEvent.bannerOpened);
          },
          onAdClosed: (ad) {
            _adEventController.add(AdEvent.bannerClosed);
          },
        ),
      );

      bannerAd.load();
      return await completer.future;
    } catch (e) {
      return Error(AdLoadFailure(message: 'Error loading banner ad: $e'));
    }
  }

  Future<Result<void>> loadInterstitialAd() async {
    if (!_isInitialized) {
      return const Error(AdLoadFailure(message: 'Ad service not initialized'));
    }

    if (isAdFreeActive) {
      return const Error(AdLoadFailure(message: 'Ad-free mode is active'));
    }

    try {
      final completer = Completer<Result<void>>();
      
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _currentInterstitialAd = ad;
            _adEventController.add(AdEvent.interstitialLoaded);
            completer.complete(const Success(null));
          },
          onAdFailedToLoad: (error) {
            _adEventController.add(AdEvent.interstitialFailedToLoad);
            completer.complete(Error(AdLoadFailure(
              message: 'Failed to load interstitial ad: ${error.message}',
              code: error.code,
            )));
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      return Error(AdLoadFailure(message: 'Error loading interstitial ad: $e'));
    }
  }

  Future<Result<void>> showInterstitialAd() async {
    if (_currentInterstitialAd == null) {
      return const Error(AdLoadFailure(message: 'No interstitial ad loaded'));
    }

    if (isAdFreeActive) {
      return const Error(AdLoadFailure(message: 'Ad-free mode is active'));
    }

    try {
      final completer = Completer<Result<void>>();
      
      _currentInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _adEventController.add(AdEvent.interstitialShown);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _currentInterstitialAd = null;
          _adEventController.add(AdEvent.interstitialDismissed);
          completer.complete(const Success(null));
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _currentInterstitialAd = null;
          _adEventController.add(AdEvent.interstitialFailedToShow);
          completer.complete(Error(AdLoadFailure(
            message: 'Failed to show interstitial ad: ${error.message}',
            code: error.code,
          )));
        },
      );

      await _currentInterstitialAd!.show();
      return await completer.future;
    } catch (e) {
      return Error(AdLoadFailure(message: 'Error showing interstitial ad: $e'));
    }
  }

  Future<Result<void>> showSyncAds() async {
    if (isAdFreeActive) {
      return const Success(null); // Skip ads if ad-free is active
    }

    try {
      // Reset counter if this is a new sync session
      final now = DateTime.now();
      if (_lastSyncTime == null || 
          now.difference(_lastSyncTime!).inMinutes > 5) {
        _adsShownInCurrentSync = 0;
      }
      _lastSyncTime = now;

      // Show exactly 2 ads per sync operation as per requirements
      if (_adsShownInCurrentSync < AppConstants.adsPerSync) {
        // Load and show interstitial ad
        final loadResult = await loadInterstitialAd();
        if (loadResult is Success) {
          final showResult = await showInterstitialAd();
          if (showResult is Success) {
            _adsShownInCurrentSync++;
            _adEventController.add(AdEvent.syncAdShown);
            
            // Award coins for watching ad
            await _awardCoinsForAd();
          }
        }
      }

      return const Success(null);
    } catch (e) {
      return Error(AdLoadFailure(message: 'Error showing sync ads: $e'));
    }
  }

  Future<void> _awardCoinsForAd() async {
    // TODO: Implement coin awarding logic
    // This should integrate with the reward system
    _adEventController.add(AdEvent.coinsAwarded);
  }

  Future<Result<void>> activateAdFreeMode(Duration duration) async {
    try {
      _isAdFreeActive = true;
      _adFreeExpiryTime = DateTime.now().add(duration);
      
      // Dispose current ads
      _currentBannerAd?.dispose();
      _currentBannerAd = null;
      _currentInterstitialAd?.dispose();
      _currentInterstitialAd = null;
      
      _adEventController.add(AdEvent.adFreeActivated);
      
      // Schedule ad-free expiry
      Timer(duration, () {
        _isAdFreeActive = false;
        _adFreeExpiryTime = null;
        _adEventController.add(AdEvent.adFreeExpired);
      });
      
      return const Success(null);
    } catch (e) {
      return Error(AdLoadFailure(message: 'Error activating ad-free mode: $e'));
    }
  }

  Duration? getAdFreeTimeRemaining() {
    if (!_isAdFreeActive || _adFreeExpiryTime == null) {
      return null;
    }
    
    final remaining = _adFreeExpiryTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  void disposeBannerAd() {
    _currentBannerAd?.dispose();
    _currentBannerAd = null;
  }

  void disposeInterstitialAd() {
    _currentInterstitialAd?.dispose();
    _currentInterstitialAd = null;
  }

  void dispose() {
    disposeBannerAd();
    disposeInterstitialAd();
    _adEventController.close();
  }
}

enum AdEvent {
  initialized,
  bannerLoaded,
  bannerFailedToLoad,
  bannerOpened,
  bannerClosed,
  interstitialLoaded,
  interstitialFailedToLoad,
  interstitialShown,
  interstitialDismissed,
  interstitialFailedToShow,
  syncAdShown,
  coinsAwarded,
  adFreeActivated,
  adFreeExpired,
}