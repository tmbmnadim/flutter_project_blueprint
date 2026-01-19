import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_services.dart';

class DemoSource {
  // Direct instantiation (or you could use GetIt/Dependency Injection here)
  final _api = ApiServices(
    baseUrl: "https://jsonplaceholder.typicode.com",
    debug: kDebugMode,
    authToken: AppConstants.token,
  );

  /// Fetch data example
  Future<dynamic> getDemoData() async {
    return await _api.get(
      path: '/posts/1',
      // Headers are handled inside ApiManager, but you can override here
    );
  }

  /// Post data example
  Future<dynamic> createDemoItem(Map<String, dynamic> body) async {
    return await _api.post(
      path: '/posts',
      body: body,
    );
  }
}