/// Project-level Supabase defaults.
///
/// These values are **safe to ship in client apps**:
/// - Supabase project URL is public.
/// - Supabase anon key is public-by-design.
///
/// IMPORTANT: Never put service_role keys or DB passwords in client code.
class SupabaseProjectDefaults {
  /// Override via `--dart-define=SUPABASE_URL=...` in real deployments.
  static const String url = 'https://damrcwmnfulghckdqxww.supabase.co';

  /// Override via `--dart-define=SUPABASE_ANON_KEY=...` in real deployments.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhbXJjd21uZnVsZ2hja2RxeHd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5OTExNTIsImV4cCI6MjA5NTU2NzE1Mn0.nocZ3AfCeFqxIYi9n8YWGkZyDvBzUiF4IPvpQ3dVSZc';
}
