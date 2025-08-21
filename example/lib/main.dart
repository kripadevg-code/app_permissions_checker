import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_permissions_checker/app_permissions_checker.dart';

void main() => runApp(const PermissionsShowcaseApp());

class PermissionsShowcaseApp extends StatelessWidget {
  const PermissionsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = Colors.teal;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Permissions Checker',
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  int _index = 0;

  // Shared state across tabs
  bool _includeSystem = false;
  List<AppPermissionInfo> _apps = [];
  bool _loading = false;

  // Control the list tab from overview actions
  final GlobalKey<_ListTabState> _listTabKey = GlobalKey<_ListTabState>();

  // Cached insights to avoid recomputing on every frame
  int _totalApps = 0;
  int _totalPermissions = 0;
  int _totalDangerous = 0;
  List<_RiskApp> _topAppsCache = [];

  void _recomputeStats() {
    _totalApps = _apps.length;
    int perms = 0;
    int dangerous = 0;
    for (final a in _apps) {
      perms += a.permissions.length;
      for (final p in a.permissions) {
        // Count only genuinely risky granted permissions
        if (p.isGenuineRisk) dangerous++;
      }
    }
    _totalPermissions = perms;
    _totalDangerous = dangerous;
    _topAppsCache = _topRiskApps(_apps, count: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Permissions Checker'),
        actions: [IconButton(tooltip: 'Filters', onPressed: _showFilters, icon: const Icon(Icons.tune_rounded))],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _OverviewTab(
            includeSystem: _includeSystem,
            loading: _loading,
            totalApps: _totalApps,
            totalPermissions: _totalPermissions,
            totalDangerous: _totalDangerous,
            onScanAll: _scanAll,
            onCheckPackages: _checkPackages,
            topApps: _topAppsCache,
            onTapApps: () => setState(() => _index = 1),
            onTapPermissions: () => setState(() => _index = 1),
            onTapDangerous: () {
              setState(() => _index = 1);
              // enable filters: dangerous + granted
              _listTabKey.currentState?.applyQuickFilter(dangerousOnly: true, grantedOnly: false);
            },
          ),
          _ListTab(apps: _apps, includeSystem: _includeSystem, loading: _loading, onRefresh: _apps.isEmpty ? _scanAll : _refresh),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.list_alt_rounded), label: 'Apps'),
        ],
      ),
      floatingActionButton: _index == 1 && !_loading ? FloatingActionButton.extended(onPressed: _scanAll, icon: const Icon(Icons.security_rounded), label: const Text('Scan All')) : null,
    );
  }

  // Actions
  Future<void> _scanAll() async {
    setState(() => _loading = true);
    try {
      // Run heavy scan in a background isolate to avoid UI jank
      final apps = await AppPermissionsChecker.getAllAppsPermissionsInBackground(
        includeSystemApps: _includeSystem,
      );
      setState(() {
        _apps = apps;
        _recomputeStats();
      });
    } catch (e) {
      _snack('Error: $e ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    if (_apps.isEmpty) return _scanAll();
    return _scanAll();
  }

  Future<void> _checkPackages() async {
    final result = await showDialog<List<String>>(context: context, builder: (_) => const _PackagesDialog());
    if (result == null || result.isEmpty) return;

    setState(() => _loading = true);
    try {
      // This call is typically lighter, but still run after setState batching
      final apps = await AppPermissionsChecker.checkPermissions(result, includeSystemApps: _includeSystem);
      setState(() {
        _apps = apps;
        _recomputeStats();
        if (_index != 1) _index = 1;
      });
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showFilters() async {
    final v = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => _FiltersSheet(includeSystem: _includeSystem),
    );
    if (v != null) setState(() => _includeSystem = v);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  List<_RiskApp> _topRiskApps(List<AppPermissionInfo> list, {int count = 5}) {
    final scored = list
        .map((a) {
          final dangerous = a.permissions.where((p) => p.isGenuineRisk).length;
          final normal = a.permissions.where((p) => p.isNormal && p.granted).length;
          // Simple score: genuinely risky weighs 3x, normal 1x
          final score = dangerous * 3 + normal;
          return _RiskApp(info: a, score: score, dangerous: dangerous);
        })
        .where((r) => r.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(count).toList();
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.includeSystem,
    required this.loading,
    required this.totalApps,
    required this.totalPermissions,
    required this.totalDangerous,
    required this.onScanAll,
    required this.onCheckPackages,
    required this.topApps,
    required this.onTapApps,
    required this.onTapPermissions,
    required this.onTapDangerous,
  });

  final bool includeSystem;
  final bool loading;
  final int totalApps;
  final int totalPermissions;
  final int totalDangerous;
  final VoidCallback onScanAll;
  final VoidCallback onCheckPackages;
  final List<_RiskApp> topApps;
  final VoidCallback onTapApps;
  final VoidCallback onTapPermissions;
  final VoidCallback onTapDangerous;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => onScanAll(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeroCard(
            title: 'Permissions Radar',
            subtitle: includeSystem ? 'Including system apps' : 'User-installed apps only',
            primary: _HeroAction(icon: Icons.security_rounded, label: 'Scan All', onPressed: loading ? null : onScanAll),
            secondary: _HeroAction(icon: Icons.apps_rounded, label: 'Check Packages', onPressed: loading ? null : onCheckPackages),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Apps', value: '$totalApps', color: cs.primary, onTap: onTapApps),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(label: 'Permissions', value: '$totalPermissions', color: cs.tertiary, onTap: onTapPermissions),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(label: 'Dangerous', value: '$totalDangerous', color: cs.error, onTap: onTapDangerous),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Top risk apps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (topApps.isEmpty)
            _EmptyBlock(icon: Icons.shield_moon, title: 'No data yet', subtitle: 'Run Scan All to generate insights.')
          else
            Column(
              children: topApps.map((r) => _RiskTile(info: r.info, score: r.score, dangerous: r.dangerous)).toList(),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.color, this.onTap});
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return onTap == null ? content : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: content);
  }
}

class _RiskApp {
  const _RiskApp({required this.info, required this.score, required this.dangerous});
  final AppPermissionInfo info;
  final int score;
  final int dangerous;
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.info, required this.score, required this.dangerous});
  final AppPermissionInfo info;
  final int score;
  final int dangerous;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => _showDetails(context),
        leading: CircleAvatar(backgroundColor: cs.errorContainer, child: const Icon(Icons.warning_amber_rounded)),
        title: Text(info.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(info.packageName, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Score $score', style: Theme.of(context).textTheme.labelLarge),
            Text('$dangerous dangerous', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final grouped = info.permissionsByCategory;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxHeight: 580),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info.appName, style: Theme.of(context).textTheme.titleLarge),
            Text(info.packageName, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: grouped.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final k = grouped.keys.elementAt(i);
                  final items = grouped[k]!;
                  return _CategorySection(title: k, items: items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAction {
  const _HeroAction({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle, required this.primary, required this.secondary});
  final String title;
  final String subtitle;
  final _HeroAction primary;
  final _HeroAction secondary;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primaryContainer, cs.tertiaryContainer]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(onPressed: primary.onPressed, icon: Icon(primary.icon), label: Text(primary.label)),
              const SizedBox(width: 12),
              OutlinedButton.icon(onPressed: secondary.onPressed, icon: Icon(secondary.icon), label: Text(secondary.label)),
            ],
          ),
        ],
      ),
    );
  }
}

// List Tab
class _ListTab extends StatefulWidget {
  const _ListTab({required this.apps, required this.includeSystem, required this.loading, required this.onRefresh});
  final List<AppPermissionInfo> apps;
  final bool includeSystem;
  final bool loading;
  final Future<void> Function() onRefresh;
  @override
  State<_ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<_ListTab> {
  String _q = '';
  bool _dangerousOnly = false;
  bool _grantedOnly = false;

  // Debounce for search input to reduce rebuilds
  Timer? _debounce;

  // Allow quick filters from overview
  void applyQuickFilter({required bool dangerousOnly, required bool grantedOnly}) {
    setState(() {
      _dangerousOnly = dangerousOnly;
      _grantedOnly = grantedOnly;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queried = _applyQuery(widget.apps, _q);
    // If any quick filters are active, hide apps that have no matching permissions
    final apps = (_dangerousOnly || _grantedOnly) ? queried.where((a) => _applyFilters(a.permissions).isNotEmpty).toList() : queried;

    // Precompute visible items' stats once per build
    final vms = apps.map((a) {
      final filtered = _applyFilters(a.permissions);
      final granted = filtered.where((p) => p.granted).length;
      final total = filtered.length;
      final pct = total == 0 ? 0.0 : granted / total;
      return _AppItemVM(info: a, granted: granted, total: total, pct: pct);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search apps…', prefixIcon: Icon(Icons.search_rounded), border: OutlineInputBorder()),
                  onChanged: (v) {
                    final text = v.trim().toLowerCase();
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 220), () {
                      if (mounted) setState(() => _q = text);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(tooltip: 'Filters', onPressed: _showListFilters, icon: const Icon(Icons.filter_list_rounded)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: widget.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: vms.isEmpty
                      ? const _EmptyBlock(icon: Icons.search_off_rounded, title: 'No results', subtitle: 'Try scanning or adjust filters.')
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemBuilder: (_, i) {
                            final vm = vms[i];
                            return _AppListTile(info: vm.info, granted: vm.granted, total: vm.total, pct: vm.pct);
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: vms.length,
                        ),
                ),
        ),
      ],
    );
  }

  // Helper methods kept inside state to access fields safely
  List<AppPermissionInfo> _applyQuery(List<AppPermissionInfo> list, String q) {
    if (q.isEmpty) return list;
    return list.where((a) => a.appName.toLowerCase().contains(q) || a.packageName.toLowerCase().contains(q)).toList();
  }

  List<PermissionDetail> _applyFilters(List<PermissionDetail> list) {
    Iterable<PermissionDetail> out = list;
    // Use the genuine risk heuristic to align with the analysis counters
    if (_dangerousOnly) out = out.where((p) => p.isGenuineRisk);
    if (_grantedOnly) out = out.where((p) => p.granted);
    return out.toList();
  }

  void _showListFilters() async {
    final res = await showModalBottomSheet<_ListFiltersResult>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ListFiltersSheet(dangerousOnly: _dangerousOnly, grantedOnly: _grantedOnly),
    );
    if (res != null) {
      setState(() {
        _dangerousOnly = res.dangerousOnly;
        _grantedOnly = res.grantedOnly;
      });
    }
  }

  // View model for list items
}

class _AppItemVM {
  _AppItemVM({required this.info, required this.granted, required this.total, required this.pct});
  final AppPermissionInfo info;
  final int granted;
  final int total;
  final double pct;
}

class _AppListTile extends StatelessWidget {
  const _AppListTile({required this.info, required this.granted, required this.total, required this.pct});
  final AppPermissionInfo info;
  final int granted;
  final int total;
  final double pct;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => _showDetails(context),
        leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: const Icon(Icons.apps_rounded)),
        title: Text(info.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info.packageName, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: pct, minHeight: 6),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$granted/$total', style: Theme.of(context).textTheme.labelLarge),
            Text('granted', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final grouped = info.permissionsByCategory;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxHeight: 580),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info.appName, style: Theme.of(context).textTheme.titleLarge),
            Text(info.packageName, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: grouped.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final k = grouped.keys.elementAt(i);
                  final items = grouped[k]!;
                  return _CategorySection(title: k, items: items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.title, required this.items});
  final String title;
  final List<PermissionDetail> items;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map(
          (p) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(p.granted ? Icons.check_circle_rounded : Icons.cancel_rounded, color: p.granted ? cs.primary : cs.error),
            title: Text(p.readableName),
            subtitle: Text(p.permission),
            trailing: Chip(label: Text(p.protectionLevel), backgroundColor: p.isDangerous ? cs.errorContainer : cs.secondaryContainer),
          ),
        ),
      ],
    );
  }
}

// Sheets & dialogs
class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.includeSystem});
  final bool includeSystem;
  @override
  Widget build(BuildContext context) {
    bool value = includeSystem;
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Global filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SwitchListTile(title: const Text('Include system apps'), value: value, onChanged: (v) => setState(() => value = v), secondary: const Icon(Icons.memory_rounded)),
            const SizedBox(height: 10),
            FilledButton.icon(onPressed: () => Navigator.of(context).pop(value), icon: const Icon(Icons.check_rounded), label: const Text('Apply')),
          ],
        ),
      ),
    );
  }
}

class _PackagesDialog extends StatefulWidget {
  const _PackagesDialog();
  @override
  State<_PackagesDialog> createState() => _PackagesDialogState();
}

class _PackagesDialogState extends State<_PackagesDialog> {
  final ctrl = TextEditingController();
  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Check packages'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(hintText: 'Comma separated packages\ncom.whatsapp, com.instagram.android', border: OutlineInputBorder()),
        minLines: 2,
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final parts = ctrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
            Navigator.pop(context, parts);
          },
          child: const Text('Check'),
        ),
      ],
    );
  }
}

class _ListFiltersResult {
  const _ListFiltersResult(this.dangerousOnly, this.grantedOnly);
  final bool dangerousOnly;
  final bool grantedOnly;
}

class _ListFiltersSheet extends StatefulWidget {
  const _ListFiltersSheet({required this.dangerousOnly, required this.grantedOnly});
  final bool dangerousOnly;
  final bool grantedOnly;
  @override
  State<_ListFiltersSheet> createState() => _ListFiltersSheetState();
}

class _ListFiltersSheetState extends State<_ListFiltersSheet> {
  late bool dangerousOnly = widget.dangerousOnly;
  late bool grantedOnly = widget.grantedOnly;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('List filters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          CheckboxListTile(value: dangerousOnly, onChanged: (v) => setState(() => dangerousOnly = v ?? false), title: const Text('Dangerous only'), secondary: const Icon(Icons.warning_amber_rounded)),
          CheckboxListTile(value: grantedOnly, onChanged: (v) => setState(() => grantedOnly = v ?? false), title: const Text('Granted only'), secondary: const Icon(Icons.verified_rounded)),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: () => Navigator.pop(context, _ListFiltersResult(dangerousOnly, grantedOnly)), icon: const Icon(Icons.check_rounded), label: const Text('Apply')),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: cs.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
