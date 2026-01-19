import 'package:flutter/foundation.dart';
import '../../../core/constants/enums.dart';
import '../../../core/network/data_state.dart';
import '../repositories/demo_repository.dart';

class DemoViewModel extends ChangeNotifier {
  final _repo = DemoRepository();

  // --- State Variables ---
  ViewModelState _status = ViewModelState.initial;
  String? _data;
  String? _errorMessage;

  // --- Getters ---
  ViewModelState get status => _status;
  String? get data => _data;
  String? get errorMessage => _errorMessage;

  // Helpers for UI
  bool get isLoading => _status == ViewModelState.loading;
  bool get isSuccess => _status == ViewModelState.success;
  bool get isError => _status == ViewModelState.error;

  /// Example: Fetch Data
  Future<void> loadData() async {
    _status = ViewModelState.loading;
    notifyListeners();

    final result = await _repo.getData();

    if (result is DataSuccess) {
      _data = result.data;
      _status = ViewModelState.success;
    } else {
      _errorMessage = result.message;
      _status = ViewModelState.error;
    }

    notifyListeners();
  }

  /// Example: Perform Action
  Future<void> createItem(String title) async {
    _status = ViewModelState.loading;
    notifyListeners();

    final result = await _repo.createItem(title);

    if (result is DataSuccess) {
      _status = ViewModelState.success;
      // Optional: Refresh list or perform other logic
    } else {
      _errorMessage = result.message;
      _status = ViewModelState.error;
    }

    notifyListeners();
  }
}
