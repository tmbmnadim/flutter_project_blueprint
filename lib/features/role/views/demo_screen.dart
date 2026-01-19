// features/demo/views/demo_screen.dart
import 'package:flutter/material.dart';
import '../view_models/demo_view_model.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // 1. Instantiate the ViewModel
  final _viewModel = DemoViewModel();

  @override
  void initState() {
    super.initState();
    // 2. Load Initial Data
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Listen to changes (Vanilla Flutter way)
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Demo Feature")),
          body: Center(
            child: _buildBody(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _viewModel.createItem("New Item"),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (_viewModel.isError) {
      return Text("Error: ${_viewModel.errorMessage}");
    }

    return Text("Data: ${_viewModel.data}");
  }
}