import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Fetch JSON', () async {
    await dotenv.load(fileName: '.env');
    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);

    // Let's find George's user ID or just fetch any trip that has members
    final data = await supabase
        .from('carpool_trips')
        .select('''
          *,
          creator:user_profiles!creator_id(*),
          members:carpool_members!inner(*, user:user_profiles!user_id(*))
        ''')
        .limit(10);
    
    // Print the raw JSON of the first one
    if (data.isNotEmpty) {
      for (final trip in data) {
         try {
            // we do this inside the real app:
            // CarpoolTrip.fromJson(trip)
            final members = trip['members'] as List<dynamic>;
            for (final member in members) {
               final user = member['user'];
               for (final entry in user.entries) {
                  if (entry.value is double) {
                     print('DOUBLE IN USER: \${entry.key} = \${entry.value}');
                  }
               }
               // Let's also check member
               for (final entry in (member as Map<String, dynamic>).entries) {
                  if (entry.value is double) {
                     print('DOUBLE IN MEMBER: \${entry.key} = \${entry.value}');
                  }
               }
            }
         } catch(e) {
         }
      }
    }
  });
}
