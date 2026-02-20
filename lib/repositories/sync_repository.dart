import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';

/// Repository responsible for timestamp-based sync and offline queue.
class SyncRepository {
  static const String _pendingOpsKey = 'pending_sync_operations';

  final ApiService _api = ApiService();

  // Singleton
  static final SyncRepository _instance = SyncRepository._internal();
  factory SyncRepository() => _instance;
  SyncRepository._internal();

  /// Merge local and backend entries using updated_at timestamps.
  /// Newer updated_at wins; fallback: backend wins if no timestamps.
  List<MoodEntry> mergeEntries(
    List<MoodEntry> localEntries,
    List<MoodEntry> backendEntries,
  ) {
    final Map<String, MoodEntry> mergedMap = {};

    for (var entry in localEntries) {
      mergedMap[entry.id] = entry;
    }

    for (var entry in backendEntries) {
      final existing = mergedMap[entry.id];
      if (existing == null) {
        mergedMap[entry.id] = entry;
      } else if (entry.updatedAt != null && existing.updatedAt != null) {
        if (entry.updatedAt!.isAfter(existing.updatedAt!)) {
          mergedMap[entry.id] = entry;
        }
      } else {
        // Fallback: backend wins if no timestamps
        mergedMap[entry.id] = entry;
      }
    }

    return mergedMap.values.toList();
  }

  /// Queue a pending operation for later sync.
  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingOperations();
    pending.add(operation);
    await prefs.setString(_pendingOpsKey, json.encode(pending));
    debugPrint('Operação pendente adicionada à fila (${pending.length} total)');
  }

  /// Get all pending operations.
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingOpsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// Flush all pending operations with simple backoff.
  /// Returns the number of successfully synced operations.
  Future<int> flushPendingOperations() async {
    final pending = await getPendingOperations();
    if (pending.isEmpty) return 0;

    debugPrint('Tentando sincronizar ${pending.length} operações pendentes...');

    final remaining = <Map<String, dynamic>>[];
    int synced = 0;
    int backoffMs = 500;

    for (var op in pending) {
      try {
        final type = op['type'] as String;
        final data = op['data'] as Map<String, dynamic>;

        if (type == 'mood_save') {
          await _api.post('/api/mood', data);
        }

        synced++;
        debugPrint('Operação sincronizada com sucesso: $type');
      } catch (e) {
        debugPrint(
          'Falha ao sincronizar operação: $e (backoff: ${backoffMs}ms)',
        );
        remaining.add(op);
        await Future.delayed(Duration(milliseconds: backoffMs));
        backoffMs = (backoffMs * 2).clamp(500, 8000);
      }
    }

    // Persist remaining failed operations
    final prefs = await SharedPreferences.getInstance();
    if (remaining.isEmpty) {
      await prefs.remove(_pendingOpsKey);
    } else {
      await prefs.setString(_pendingOpsKey, json.encode(remaining));
    }

    debugPrint('Sincronização: $synced OK, ${remaining.length} pendentes');
    return synced;
  }

  /// Check if there are pending operations.
  Future<bool> hasPendingOperations() async {
    final ops = await getPendingOperations();
    return ops.isNotEmpty;
  }
}
