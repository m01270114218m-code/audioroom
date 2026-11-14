import 'package:audioroom/widgets/participant_block.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/participant.dart';

class ParticipantsContainer extends StatelessWidget {
  ParticipantsContainer(this.roomName, {super.key});

  final String roomName;
  final SupabaseClient _db = Supabase.instance.client;

  Future<Map<String, dynamic>?> _loadRoom() async {
    final result = await _db
        .from('rooms')
        .select('id')
        .eq('title', roomName)
        .limit(1)
        .maybeSingle();
    return result;
  }

  Future<Map<String, dynamic>?> _loadProfile(String userId) async {
    final result = await _db
        .from('profiles')
        .select('display_name,avatar_url')
        .eq('id', userId)
        .maybeSingle();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadRoom(),
      builder: (context, roomSnapshot) {
        if (roomSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (roomSnapshot.hasError) {
          return const Center(child: Text('Could not load room'));
        }
        final room = roomSnapshot.data;
        if (room == null) return const Center(child: Text('Room not found'));
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _db
              .from('room_members')
              .stream(primaryKey: ['room_id', 'user_id'])
              .eq('room_id', room['id']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load participants'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final members = snapshot.data!;
            if (members.isEmpty) {
              return const Center(child: Text('No participants yet'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.5 / 3,
              ),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final userId = member['user_id'] as String;
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _loadProfile(userId),
                  builder: (context, profileSnapshot) {
                    final profile = profileSnapshot.data ?? {};
                    final role = member['role'] as String? ?? 'member';
                    final displayName = profile['display_name'] as String?;
                    final avatarUrl = profile['avatar_url'] as String?;
                    final participant = Participant(
                      email: userId,
                      name: displayName != null && displayName.isNotEmpty
                          ? displayName
                          : 'User ${userId.substring(0, userId.length < 6 ? userId.length : 6)}',
                      dpUrl: avatarUrl ??
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                      isAdmin: role == 'owner' || role == 'admin',
                      isMicOn: false,
                      isModerator: role == 'admin',
                      isSpeaker: true,
                      isSpeaking: false,
                    );
                    return ParticipantBlock(participant: participant);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
