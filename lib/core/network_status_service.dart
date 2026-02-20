import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/sync_repository.dart';

/// Service that monitors network connectivity and triggers pending sync.
class NetworkStatusService extends GetxService {
  final RxBool isOnline = true.obs;
  final SyncRepository _syncRepo = SyncRepository();

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialStatus();
    _subscription = Connectivity().onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    _onChanged(results);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final wasOffline = !isOnline.value;
    final nowOnline = results.any((r) => r != ConnectivityResult.none);

    isOnline.value = nowOnline;

    if (wasOffline && nowOnline) {
      debugPrint('Conexão restaurada — sincronizando operações pendentes...');
      _syncPendingOperations();
    }
  }

  Future<void> _syncPendingOperations() async {
    try {
      final synced = await _syncRepo.flushPendingOperations();
      if (synced > 0) {
        debugPrint('$synced operações sincronizadas com sucesso');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar: $e');
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
