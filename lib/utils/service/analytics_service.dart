import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalyticsService extends ChangeNotifier {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static AnalyticsService of(BuildContext context) => context.read<AnalyticsService>();
}
