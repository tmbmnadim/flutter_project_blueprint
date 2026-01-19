import '../../../core/network/data_state.dart';
import '../../../core/network/repository_error_handler.dart';
import '../sources/demo_source.dart';

class DemoRepository {
  final _source = DemoSource();

  // Retrieve a Model (e.g., String for this demo)
  Future<DataState<String>> getData() {
    return RepositoryErrorHandler.call(
      network: () async {
        final response = await _source.getDemoData();
        // Parse your model here. For demo, we just return the title.
        return response['title'] as String;
      },
      proxyMessage: "Failed to fetch demo data",
    );
  }

  // Perform an Action (e.g., Create)
  Future<DataState<bool>> createItem(String title) {
    return RepositoryErrorHandler.call(
      network: () async {
        await _source.createDemoItem({'title': title});
        return true; // Return true if successful
      },
      proxyMessage: "Failed to create item",
    );
  }
}