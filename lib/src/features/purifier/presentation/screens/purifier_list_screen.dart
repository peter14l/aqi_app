import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aqi_app/src/features/purifier/presentation/providers/purifier_provider.dart';
import 'package:aqi_app/src/features/purifier/presentation/widgets/purifier_card.dart';

class PurifierListScreen extends ConsumerStatefulWidget {
  const PurifierListScreen({super.key});

  @override
  ConsumerState<PurifierListScreen> createState() => _PurifierListScreenState();
}

class _PurifierListScreenState extends ConsumerState<PurifierListScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(purifierListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final purifiersAsync = ref.watch(purifierListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Purifiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/purifier/add'),
          ),
        ],
      ),
      body: purifiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (purifiers) {
          if (purifiers.isEmpty) {
            return const Center(
              child: Text('No purifiers found. Add one to get started!'),
            );
          }
          return ListView.builder(
            itemCount: purifiers.length,
            itemBuilder: (context, index) {
              final purifier = purifiers[index];
              return PurifierCard(purifier: purifier);
            },
          );
        },
      ),
    );
  }
}
