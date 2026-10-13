import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/obsidian_theme.dart';
import 'core/widgets/dot_lan_animated_logo.dart';
import 'core/widgets/jazdot_suite_drawer.dart';
import 'features/lan_cubit/lan_cubit.dart';
import 'features/lan_cubit/lan_state.dart';
import 'features/radar/presentation/radar_tab.dart';
import 'features/inventory/presentation/inventory_tab.dart';
import 'features/camera_sentry/presentation/camera_sentry_tab.dart';
import 'features/diagnostics/presentation/diagnostics_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DotLanApp());
}

/**
 * DotLan Application Root.
 * 
 * Implements Jazdot Enterprises Obsidian Luxury CAD Design System
 * with full reactive state management and 4-tab network sentry architecture.
 */
class DotLanApp extends StatelessWidget {
  const DotLanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ObsidianTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'DotLan',
          debugShowCheckedModeBanner: false,
          theme: ObsidianTheme.lightThemeData,
          darkTheme: ObsidianTheme.darkThemeData,
          themeMode: themeMode,
          home: BlocProvider(
            create: (_) => LanCubit()..startScan(),
            child: const DotLanDashboardScreen(),
          ),
        );
      },
    );
  }
}

class DotLanDashboardScreen extends StatefulWidget {
  const DotLanDashboardScreen({super.key});

  @override
  State<DotLanDashboardScreen> createState() => _DotLanDashboardScreenState();
}

class _DotLanDashboardScreenState extends State<DotLanDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.bgBase,
      drawer: const JazdotSuiteDrawer(),
      appBar: AppBar(
        backgroundColor: ObsidianTheme.bgBase,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: ObsidianTheme.textPrimary, size: 20),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const DotLanAnimatedLogo(
          size: 28,
          variant: LogoVariant.compact,
          showWordmark: true,
        ),
        actions: [
          BlocBuilder<LanCubit, LanState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isScanning ? Icons.stop_circle_outlined : Icons.refresh,
                  color: ObsidianTheme.accentGold,
                  size: 20,
                ),
                onPressed: () {
                  context.read<LanCubit>().startScan();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              ObsidianTheme.isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: ObsidianTheme.textSecondary,
              size: 20,
            ),
            onPressed: () {
              final current = ObsidianTheme.themeModeNotifier.value;
              ObsidianTheme.themeModeNotifier.value =
                  current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ObsidianTheme.borderSubtle)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ObsidianTheme.accentGold,
              indicatorWeight: 2.0,
              labelColor: ObsidianTheme.accentGold,
              unselectedLabelColor: ObsidianTheme.textTertiary,
              labelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
              ),
              tabs: const [
                Tab(icon: Icon(Icons.radar, size: 16), text: 'RADAR'),
                Tab(icon: Icon(Icons.devices, size: 16), text: 'INVENTORY'),
                Tab(icon: Icon(Icons.videocam_outlined, size: 16), text: 'SENTRY'),
                Tab(icon: Icon(Icons.router_outlined, size: 16), text: 'GATEWAY'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RadarTab(),
          InventoryTab(),
          CameraSentryTab(),
          DiagnosticsTab(),
        ],
      ),
    );
  }
}
