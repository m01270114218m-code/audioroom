import 'package:audioroom/screens/home_screen.dart';
import 'package:audioroom/models/room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  static final SupabaseClient _db = Supabase.instance.client;

  static String get _userId {
    final user = _db.auth.currentUser;
    if (user == null) throw AuthException('Please sign in first.');
    return user.id;
  }

  static Future createRoom({
    required String roomName,
    required String description,
    bool isPrivate = false,
  }) async {
    final room = await _db
        .from('rooms')
        .insert({
          'owner_id': _userId,
          'title': roomName.trim(),
          'description': description.trim(),
          'room_type': isPrivate ? 'private' : 'public',
          'status': 'active',
        })
        .select('id, title, description')
        .single();

    await _db.from('room_members').insert({
      'room_id': room['id'],
      'user_id': _userId,
      'role': 'owner',
    });

    Get.snackbar(
      'Room created',
      'The room is saved. Live voice will be enabled after secure LiveKit token setup.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return AudioRoom(
      name: room['title'] as String,
      description: (room['description'] ?? '') as String,
    );
  }

  static Future deleteRoom({required String roomName}) async {
    final room = await _db
        .from('rooms')
        .select('id')
        .eq('title', roomName)
        .eq('owner_id', _userId)
        .maybeSingle();

    if (room == null) return;
    await _db.from('rooms').delete().eq('id', room['id']);
    Get.offAll(() => HomeScreen());
  }

  static Future joinRoom({
    required String roomName,
    required String description,
  }) async {
    final room = await _db
        .from('rooms')
        .select('id, title, description')
        .eq('title', roomName)
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (room == null) {
      throw PostgrestException(message: 'This room is no longer available.');
    }

    await _db.from('room_members').upsert(
      {
        'room_id': room['id'],
        'user_id': _userId,
        'role': 'member',
      },
      onConflict: 'room_id,user_id',
      ignoreDuplicates: true,
    );

    Get.snackbar(
      'Joined room',
      'You joined the room. Live voice will be enabled after secure LiveKit token setup.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return AudioRoom(
      name: room['title'] as String,
      description: (room['description'] ?? '') as String,
    );
  }

  static Future leaveRoom({required String roomName}) async {
    final room = await _db
        .from('rooms')
        .select('id')
        .eq('title', roomName)
        .limit(1)
        .maybeSingle();

    if (room == null) return;
    await _db
        .from('room_members')
        .delete()
        .eq('room_id', room['id'])
        .eq('user_id', _userId);
  }
}
