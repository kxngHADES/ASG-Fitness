import 'package:flutter/material.dart';

import 'body_stats_tab.dart';
import 'progression_tab.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Body Stats'),
              Tab(text: 'Progression'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BodyStatsTab(),
            ProgressionTab(),
          ],
        ),
      ),
    );
  }
}
