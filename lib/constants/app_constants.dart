// App constants for the social blogger application

class AppConstants {
  // App information
  static const String appName = 'Social Blogger';
  static const String appVersion = '1.0.0';

  // Database constants
  static const String dbName = 'social_blogger.db';
  static const int dbVersion = 1;

  // Table names
  static const String postsTable = 'posts';

  // Social media platforms
  static const List<String> socialPlatforms = [
    'Facebook',
    'Twitter',
    'Instagram',
    'LinkedIn',
    'WordPress',
    'Tumblr',
    'Medium',
  ];

  // Images
  static const int imageQuality = 80;
  static const String imagesDirectory = 'social_blogger_images';

  // Preferences
  static const String prefsAuthKey = 'auth_tokens';
}
