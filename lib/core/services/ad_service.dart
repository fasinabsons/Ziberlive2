import 'dart:async';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isAdFreeMode = false;
  DateTime? _adFreeExpiresAt;
  Timer? _adFreeTimer;
  
  final StreamController<bool> _adFreeStatusController = StreamController<bool>.broadcast();
  Stream<bool> get adFreeStatusStream => _adFreeStatusController.stream;

  bool get isAdFreeMode => _isAdFreeMode;
  DateTime? get adFreeExpiresAt => _adFreeExpiresAt;

  Future<void> initialize() async {
    // Load saved ad-free status from storage
    await _loadAdFreeStatus();
    
    // Check if current ad-free period has expired
    _checkAdFreeExpiration();
  }

  Future<void> activateAdFreeMode(Duration duration) async {
    _isAdFreeMode = true;
    _adFreeExpiresAt = DateTime.now().add(duration);
    
    // Cancel existing timer
    _adFreeTimer?.cancel();
    
    // Set up expiration timer
    _adFreeTimer = Timer(duration, () {
      _deactivateAdFreeMode();
    });
    
    // Save to storage
    await _saveAdFreeStatus();
    
    // Notify listeners
    _adFreeStatusController.add(true);
    
    if (kDebugMode) {
      print('Ad-free mode activated until $_adFreeExpiresAt');
    }
  }

  void _deactivateAdFreeMode() {
    _isAdFreeMode = false;
    _adFreeExpiresAt = null;
    _adFreeTimer?.cancel();
    _adFreeTimer = null;
    
    // Save to storage
    _saveAdFreeStatus();
    
    // Notify listeners
    _adFreeStatusController.add(false);
    
    if (kDebugMode) {
      print('Ad-free mode expired');
    }
  }

  Future<void> _loadAdFreeStatus() async {
    // TODO: Load from SharedPreferences or secure storage
    // For now, using mock data
    // final prefs = await SharedPreferences.getInstance();
    // _isAdFreeMode = prefs.getBool('ad_free_mode') ?? false;
    // final expiresAtString = prefs.getString('ad_free_expires_at');
    // if (expiresAtString != null) {
    //   _adFreeExpiresAt = DateTime.parse(expiresAtString);
    // }
  }

  Future<void> _saveAdFreeStatus() async {
    // TODO: Save to SharedPreferences or secure storage
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('ad_free_mode', _isAdFreeMode);
    // if (_adFreeExpiresAt != null) {
    //   await prefs.setString('ad_free_expires_at', _adFreeExpiresAt!.toIso8601String());
    // } else {
    //   await prefs.remove('ad_free_expires_at');
    // }
  }

  void _checkAdFreeExpiration() {
    if (_isAdFreeMode && _adFreeExpiresAt != null) {
      final now = DateTime.now();
      if (now.isAfter(_adFreeExpiresAt!)) {
        // Ad-free period has expired
        _deactivateAdFreeMode();
      } else {
        // Set up timer for remaining time
        final remainingTime = _adFreeExpiresAt!.difference(now);
        _adFreeTimer = Timer(remainingTime, () {
          _deactivateAdFreeMode();
        });
      }
    }
  }

  bool shouldShowAd() {
    return !_isAdFreeMode;
  }

  Future<void> showBannerAd() async {
    if (!shouldShowAd()) return;
    
    // TODO: Implement actual ad display logic
    if (kDebugMode) {
      print('Showing banner ad');
    }
  }

  Future<void> showInterstitialAd() async {
    if (!shouldShowAd()) return;
    
    // TODO: Implement actual ad display logic
    if (kDebugMode) {
      print('Showing interstitial ad');
    }
  }

  Future<void> showRewardedAd({
    required Function() onRewarded,
    required Function() onFailed,
  }) async {
    // Rewarded ads are always shown, even in ad-free mode
    // as they provide value to the user
    
    // TODO: Implement actual rewarded ad logic
    if (kDebugMode) {
      print('Showing rewarded ad');
    }
    
    // Simulate ad completion
    await Future.delayed(const Duration(seconds: 2));
    onRewarded();
  }

  Future<void> showSyncAds() async {
    if (!shouldShowAd()) return;
    
    // Show exactly 2 banner ads during sync as per requirements
    await showBannerAd();
    await Future.delayed(const Duration(seconds: 1));
    await showBannerAd();
    
    if (kDebugMode) {
      print('Showed 2 sync ads');
    }
  }

  Duration? getRemainingAdFreeTime() {
    if (!_isAdFreeMode || _adFreeExpiresAt == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(_adFreeExpiresAt!)) return null;
    
    return _adFreeExpiresAt!.difference(now);
  }

  String getAdFreeStatusText() {
    if (!_isAdFreeMode) return 'Ads enabled';
    
    final remainingTime = getRemainingAdFreeTime();
    if (remainingTime == null) return 'Ad-free expired';
    
    if (remainingTime.inDays > 0) {
      return 'Ad-free for ${remainingTime.inDays} more days';
    } else if (remainingTime.inHours > 0) {
      return 'Ad-free for ${remainingTime.inHours} more hours';
    } else {
      return 'Ad-free for ${remainingTime.inMinutes} more minutes';
    }
  }

  void dispose() {
    _adFreeTimer?.cancel();
    _adFreeStatusController.close();
  }
}