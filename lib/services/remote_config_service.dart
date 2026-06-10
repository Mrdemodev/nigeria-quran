import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  late final FirebaseRemoteConfig _rc;
  bool _ready = false;

  // ── Default values (used offline / before fetch) ──────────────────────────
  static const Map<String, dynamic> _defaults = {
    // Ads
    'ads_enabled':              true,
    'banner_ad_unit_id':        'ca-app-pub-3951289981861959/9276401970',
    'interstitial_ad_unit_id':  'ca-app-pub-3951289981861959/3703635384',
    'rewarded1_ad_unit_id':     'ca-app-pub-3951289981861959/2666424883',
    'rewarded2_ad_unit_id':     'ca-app-pub-3951289981861959/5368070841',
    // Announcement banner (shown in home screen header)
    'announcement_enabled':     false,
    'announcement_text':        '',
    'announcement_url':         '',
    'announcement_bg_color':    '#1A6B3A',  // hex colour string
    // Maintenance mode — shows a blocking screen
    'maintenance_mode':         false,
    'maintenance_message':      'The app is undergoing maintenance. Please check back shortly.',
    // Force update
    'force_update_enabled':     false,
    'force_update_min_build':   0,
    'force_update_url':         'https://play.google.com/store/apps/details?id=com.nigeriaquran.nigeria_quran',
    // Daily verse override (JSON: {"surah":1,"ayah":1})
    'daily_verse_override':     '',
    // Feature flags
    'show_ads_in_surah':        true,
    'prayer_times_enabled':     true,
    'downloads_enabled':        true,
  };

  Future<void> init() async {
    try {
      _rc = FirebaseRemoteConfig.instance;
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _rc.setDefaults(_defaults);
      await _rc.fetchAndActivate();
      _ready = true;
      debugPrint('RemoteConfig ready');
    } catch (e) {
      debugPrint('RemoteConfig init error: $e');
      // App works with defaults if Firebase is unreachable
    }
  }

  // ── Ads ───────────────────────────────────────────────────────────────────
  bool   get adsEnabled            => _get<bool>  ('ads_enabled');
  String get bannerAdUnitId        => _get<String>('banner_ad_unit_id');
  String get interstitialAdUnitId  => _get<String>('interstitial_ad_unit_id');
  String get rewarded1AdUnitId     => _get<String>('rewarded1_ad_unit_id');
  String get rewarded2AdUnitId     => _get<String>('rewarded2_ad_unit_id');

  // ── Announcement ─────────────────────────────────────────────────────────
  bool   get announcementEnabled   => _get<bool>  ('announcement_enabled');
  String get announcementText      => _get<String>('announcement_text');
  String get announcementUrl       => _get<String>('announcement_url');
  String get announcementBgColor   => _get<String>('announcement_bg_color');

  // ── Maintenance ───────────────────────────────────────────────────────────
  bool   get maintenanceMode       => _get<bool>  ('maintenance_mode');
  String get maintenanceMessage    => _get<String>('maintenance_message');

  // ── Force update ─────────────────────────────────────────────────────────
  bool   get forceUpdateEnabled    => _get<bool>  ('force_update_enabled');
  int    get forceUpdateMinBuild   => _get<int>   ('force_update_min_build');
  String get forceUpdateUrl        => _get<String>('force_update_url');

  // ── Daily verse override ──────────────────────────────────────────────────
  String get dailyVerseOverride    => _get<String>('daily_verse_override');

  // ── Feature flags ────────────────────────────────────────────────────────
  bool   get showAdsInSurah        => _get<bool>  ('show_ads_in_surah');
  bool   get prayerTimesEnabled    => _get<bool>  ('prayer_times_enabled');
  bool   get downloadsEnabled      => _get<bool>  ('downloads_enabled');

  T _get<T>(String key) {
    if (!_ready) return _defaults[key] as T;
    if (T == bool)   return _rc.getBool(key)   as T;
    if (T == int)    return _rc.getInt(key)    as T;
    if (T == double) return _rc.getDouble(key) as T;
    return _rc.getString(key) as T;
  }
}
