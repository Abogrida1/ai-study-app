import 'package:supabase_flutter/supabase_flutter.dart';

/// A global reference to the Supabase client.
/// Use this across the application to perform database queries, authentication, etc.
final supabase = Supabase.instance.client;
