import 'package:audioroom/screens/profile_screen.dart';
import 'package:audioroom/services/room_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioroom/screens/settings_screen.dart';
import 'package:audioroom/screens/search_rooms_screen.dart';
import 'package:audioroom/screens/analytics_screen.dart';
import 'package:audioroom/screens/advanced_chat_screen.dart';
import 'package:audioroom/screens/advanced_room_management_screen.dart';
import 'package:audioroom/widgets/create_room_dialog.dart';
import 'package:audioroom/widgets/ninja_ui_components.dart';
import 'package:audioroom/screens/simple_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> rooms = [];
  bool _isLoadingRooms = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rows = await Supabase.instance.client
          .from('rooms')
          .select('id,title,description,room_members(count)')
          .eq('status', 'active')
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        rooms = (rows as List).map<Map<String, dynamic>>((row) {
          final members = (row['room_members'] as List?) ?? [];
          final count = members.isEmpty ? 0 : (members.first['count'] as int? ?? 0);
          return {
            'id': row['id'],
            'name': row['title'],
            'description': row['description'] ?? '',
            'total_participants': count,
          };
        }).toList();
      });
    } catch (error) {
      if (mounted) Get.snackbar('Rooms unavailable', 'Could not load rooms from Supabase.');
    } finally {
      if (mounted) setState(() => _isLoadingRooms = false);
    }
  }

  void _addRoom(Map<String, dynamic> newRoom) {
    _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NinjaPulseEffect(
              child: Icon(Icons.meeting_room, color: Colors.white, size: 24),
            ),
            SizedBox(width: 8),
            NinjaAnimatedText(
              text: "NINJA ROOMS",
              textStyle: GoogleFonts.orbitron(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => SearchRoomsScreen(allRooms: rooms));
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => UserProfileScreen());
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: NinjaPulseEffect(
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.defaultDialog(
              title: 'CREATE NINJA ROOM',
              titlePadding: EdgeInsets.only(top: 20),
              titleStyle: GoogleFonts.orbitron(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              backgroundColor: Colors.black,
              content: CreateRoomDialog(
                onRoomCreated: _addRoom,
              ),
              radius: 12.0,
            );
          },
          label: Text(
            'CREATE ROOM',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          icon: Icon(Icons.add_circle_outline),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(child: Text('No rooms yet. Create the first room.'))
              : Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: NinjaCard(
                onTap: () async {
                  try {
                    await RoomService.joinRoom(
                      roomName: room['name'],
                      description: room['description'],
                    );
                    Get.to(() => AdvancedChatScreen(roomName: room['name']));
                  } catch (error) {
                    Get.snackbar('Could not join room', error.toString());
                  }
                },
                child: ListTile(
                  leading: NinjaPulseEffect(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.groups,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  title: Text(
                    room["name"],
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  subtitle: Text(
                    room["description"],
                    style: GoogleFonts.rajdhani(
                      color: Colors.grey.shade300,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: NinjaShimmerEffect(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        Text(
                          '${room["total_participants"]}',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF111111)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NinjaPulseEffect(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.flash_on,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                NinjaAnimatedText(
                  text: 'NINJA ROOM',
                  textStyle: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Master the art of audio communication',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: Colors.white),
                  title: Text('Room Dojo', style: GoogleFonts.orbitron(color: Colors.white)),
                  subtitle: Text('Advanced room management', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.grey.shade400)),
                  onTap: () {
                    Get.back();
                    Get.to(() => AdvancedRoomManagementScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.analytics, color: Colors.white),
                  title: Text('Analytics', style: GoogleFonts.orbitron(color: Colors.white)),
                  subtitle: Text('View your usage statistics', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.grey.shade400)),
                  onTap: () {
                    Get.back();
                    Get.to(() => AnalyticsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.search, color: Colors.white),
                  title: Text('Find Rooms', style: GoogleFonts.orbitron(color: Colors.white)),
                  subtitle: Text('Search and filter rooms', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.grey.shade400)),
                  onTap: () {
                    Get.back();
                    Get.to(() => SearchRoomsScreen(allRooms: rooms));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text('Settings', style: GoogleFonts.orbitron(color: Colors.white)),
                  subtitle: Text('App preferences and controls', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.grey.shade400)),
                  onTap: () {
                    Get.back();
                    Get.to(() => SettingsScreen());
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey.shade400),
                  title: Text('About', style: GoogleFonts.orbitron(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    Get.defaultDialog(
                      title: 'About Ninja AudioRoom',
                      titleStyle: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.w700),
                      middleText: 'Ninja AudioRoom v2.0.0\n\nMaster the art of audio communication with advanced ninja features.',
                      middleTextStyle: GoogleFonts.rajdhani(color: Colors.grey.shade300),
                      textConfirm: 'CLOSE',
                      confirmTextColor: Colors.black,
                      buttonColor: Colors.white,
                      backgroundColor: Colors.black,
                      onConfirm: () => Get.back(),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.feedback, color: Colors.grey.shade400),
                  title: Text('Send Feedback', style: GoogleFonts.orbitron(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    Get.defaultDialog(
                      title: 'Feedback',
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Your feedback...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                      textConfirm: 'Send',
                      textCancel: 'Cancel',
                      onConfirm: () {
                        Get.back();
                        Get.snackbar('Thank you!', 'Your feedback has been sent.', backgroundColor: Colors.green, colorText: Colors.white);
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Sign out', style: GoogleFonts.orbitron(color: Colors.white)),
                  onTap: () async {
                    Get.back();
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
