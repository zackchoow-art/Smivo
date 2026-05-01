import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/data/models/user_feedback.dart';

void main() async {
  final client = SupabaseClient(
    'https://sztrbkfdcldwaifjkkol.supabase.co',
    'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj',
  );

  try {
    final data = await client
        .from('user_feedbacks')
        .select()
        .eq('user_id', '64a5d296-3c36-411e-a559-3c30b2c660af')
        .order('created_at', ascending: false);

    print('Fetched ${data.length} rows.');
    for (final json in data) {
      try {
        final feedback = UserFeedback.fromJson(json);
        print('Parsed: ${feedback.title}');
      } catch (e, st) {
        print('Error parsing json: $json');
        print('Exception: $e');
        print('StackTrace: $st');
      }
    }
  } catch (e, st) {
    print('Failed to fetch: $e');
    print(st);
  }
}
