import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) => KeyedSubtree(
        key: const ValueKey('data'),
        child: data(d),
      ),
      error: (e, st) {
        if (error != null) return error!(e, st);
        return Center(
          key: const ValueKey('error'),
          child: Text(
            e.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        );
      },
      loading: () {
        if (loading != null) return loading!();
        return const Center(
          key: const ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class SliverAsyncValueWidget<T> extends StatelessWidget {
  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) => KeyedSubtree(
        key: const ValueKey('sliver_data'),
        child: data(d),
      ),
      error: (e, st) {
        if (error != null) return error!(e, st);
        return SliverToBoxAdapter(
          key: const ValueKey('sliver_error'),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ),
        );
      },
      loading: () {
        if (loading != null) return loading!();
        return const SliverToBoxAdapter(
          key: const ValueKey('sliver_loading'),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
