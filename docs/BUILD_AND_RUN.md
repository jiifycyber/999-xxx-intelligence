# Build and run

## Flutter
cd app
flutter pub get

flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY

## Apply migrations
Apply `001_999xxx_core.sql` first, then `002_v2_catalog_commerce.sql`.

## External provider flags
Once a provider is actually connected, pass its configured name:
--dart-define=VIDEO_PROVIDER=your_provider
--dart-define=PAYMENT_PROVIDER=your_provider
--dart-define=VERIFICATION_PROVIDER=your_provider

The Status screen will then reflect configuration state.
