import 'dart:io' show Platform;

import 'package:finguard/core/utils/version_utils.dart';
import 'dart:async';

import 'package:finguard/features/app_config/app_config_repository.dart';
import 'package:finguard/features/app_version/data/app_version_repository.dart';
import 'package:finguard/features/app_version/data/model/app_version_response.dart';
import 'package:finguard/features/subscription/data/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/core/storage/local_storage.dart';
import 'package:finguard/features/auth/data/auth_repository.dart';
import 'package:finguard/features/user/data/user_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/model/profile_model.dart';

class ProfileUpdateStatus {
  final bool maintenanceMode;
  final bool hasUpdate;
  final bool forceUpdate;
  final String currentVersion;
  final String? latestVersion;
  final String? message;
  final String? storeUrl;

  const ProfileUpdateStatus({
    required this.maintenanceMode,
    required this.hasUpdate,
    required this.forceUpdate,
    required this.currentVersion,
    this.latestVersion,
    this.message,
    this.storeUrl,
  });
}

class ProfileViewmodel extends ChangeNotifier {
  static const _androidProductId = 'TODO';
  static const _iosProductId = 'TODO';

  final UserRepository userRepository;
  final AuthRepository authRepository;
  final LocalStorage localStorage;
  final ApiClient apiClient;
  final AppVersionRepository appVersionRepository;
  final SubscriptionRepository subscriptionRepository;
  final AppConfigRepository appConfigRepository;

  String get _platformId => Platform.isAndroid ? 'ANDROID' : 'IOS';

  ProfileViewmodel({
    required this.userRepository,
    required this.authRepository,
    required this.localStorage,
    required this.apiClient,
    required this.appVersionRepository,
    required this.subscriptionRepository,
    required this.appConfigRepository,
  });

  ProfileModel? profile;
  bool isLoading = false;
  bool isSigningOut = false;
  bool isCheckingUpdate = false;
  bool isSubscribing = false;
  bool subscriptionEnabled = false;
  String? appVersion;
  String? error;

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      profile = await userRepository.getMe();

      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = "${packageInfo.version} (${packageInfo.buildNumber})";

      final config = await appConfigRepository.getConfig(
        platform: _platformId,
        version: packageInfo.version,
      );
      subscriptionEnabled = config.subscriptionEnabled;

      error = null;
    } catch (e) {
      error = "Failed to load profile";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    if (isSigningOut) return false;

    try {
      isSigningOut = true;
      error = null;
      notifyListeners();

      final refreshToken = await localStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await authRepository.logout(refreshToken: refreshToken);
        } catch (_) {}
      }

      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      await localStorage.clearAuthSession();
      await localStorage.clearOnboardingState();
      await localStorage.markLoggedOut();
      await apiClient.refreshCachedSessionFromStorage();

      profile = null;
      return true;
    } catch (_) {
      error = "Failed to sign out";
      return false;
    } finally {
      isSigningOut = false;
      notifyListeners();
    }
  }

  Future<ProfileUpdateStatus?> checkForUpdates() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    try {
      isCheckingUpdate = true;
      notifyListeners();

      final packageInfo = await PackageInfo.fromPlatform();
      final response = await appVersionRepository.checkVersion(
        platform: Platform.isAndroid ? 'android' : 'ios',
        version: packageInfo.version,
      );

      return _toUpdateStatus(packageInfo.version, response);
    } finally {
      isCheckingUpdate = false;
      notifyListeners();
    }
  }

  ProfileUpdateStatus _toUpdateStatus(
    String currentVersion,
    AppVersionResponse response,
  ) {
    final forceUpdate = response.forceUpdate || response.mustUpdate;
    final hasOptionalUpdate =
        response.latestVersion.isNotEmpty &&
        compareVersion(response.latestVersion, currentVersion) > 0;

    return ProfileUpdateStatus(
      maintenanceMode: response.maintenanceMode,
      hasUpdate: forceUpdate || hasOptionalUpdate,
      forceUpdate: forceUpdate,
      currentVersion: currentVersion,
      latestVersion: response.latestVersion,
      message: response.maintenanceMessage,
      storeUrl: response.storeUrl,
    );
  }

  Future<void> subscribeToPro() async {
    if (isSubscribing) return;
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw StateError('In-app purchase is supported on Android/iOS only.');
    }

    final productId = Platform.isAndroid ? _androidProductId : _iosProductId;
    final platform = _platformId;
    final iap = InAppPurchase.instance;

    StreamSubscription<List<PurchaseDetails>>? sub;

    try {
      isSubscribing = true;
      notifyListeners();

      final available = await iap.isAvailable();
      if (!available) {
        throw StateError('Store is not available right now.');
      }

      final productResponse = await iap.queryProductDetails({productId});
      if (productResponse.error != null) {
        throw StateError(productResponse.error!.message);
      }
      if (productResponse.productDetails.isEmpty) {
        throw StateError('Subscription product is not configured.');
      }

      final completer = Completer<void>();
      sub = iap.purchaseStream.listen((purchases) async {
        for (final purchase in purchases) {
          if (purchase.productID != productId) continue;

          if (purchase.status == PurchaseStatus.pending) {
            continue;
          }

          if (purchase.status == PurchaseStatus.error) {
            final message = purchase.error?.message ?? 'Purchase failed.';
            if (!completer.isCompleted) {
              completer.completeError(StateError(message));
            }
            if (purchase.pendingCompletePurchase) {
              await iap.completePurchase(purchase);
            }
            continue;
          }

          if (purchase.status == PurchaseStatus.canceled) {
            if (!completer.isCompleted) {
              completer.completeError(StateError('Purchase cancelled.'));
            }
            if (purchase.pendingCompletePurchase) {
              await iap.completePurchase(purchase);
            }
            continue;
          }

          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            final transactionData =
                purchase.verificationData.serverVerificationData;
            if (transactionData.isEmpty) {
              if (!completer.isCompleted) {
                completer.completeError(
                  StateError('Missing purchase verification data.'),
                );
              }
            } else {
              await subscriptionRepository.purchaseSubscription(
                platform: platform,
                productId: purchase.productID,
                transactionData: transactionData,
              );
              if (!completer.isCompleted) {
                completer.complete();
              }
            }

            if (purchase.pendingCompletePurchase) {
              await iap.completePurchase(purchase);
            }
          }
        }
      });

      final purchaseParam = PurchaseParam(
        productDetails: productResponse.productDetails.first,
      );
      final started = await iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!started) {
        throw StateError('Unable to start purchase flow.');
      }

      await completer.future.timeout(const Duration(minutes: 2));
      await loadProfile();
    } finally {
      await sub?.cancel();
      isSubscribing = false;
      notifyListeners();
    }
  }
}
