import 'package:flutter/material.dart';
import 'package:audioroom/services/room_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enhanced_room.dart';

class CreateEnhancedRoomScreen extends StatefulWidget {
  @override
  State<CreateEnhancedRoomScreen> createState() => _CreateEnhancedRoomScreenState();
}

class _CreateEnhancedRoomScreenState extends State<CreateEnhancedRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tagsController = TextEditingController();
  
  // Form state
  RoomType _selectedType = RoomType.public;
  RoomCategory _selectedCategory = RoomCategory.general;
  int _maxParticipants = 50;
  bool _isPasswordProtected = false;
  DateTime? _scheduledTime;
  int _estimatedDuration = 60;
  bool _isRecordingEnabled = false;
  bool _isTranscriptionEnabled = false;
  bool _allowScreenSharing = true;
  bool _allowReactions = true;
  int _speakingTimeLimit = 0;
  List<String> _tags = [];
  String? _backgroundMusic;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1421),
      appBar: AppBar(
        title: Text(
          'Create Room',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF03DAC6),
          labelColor: Color(0xFF03DAC6),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Basic', icon: Icon(Icons.info_outline, size: 16)),
            Tab(text: 'Settings', icon: Icon(Icons.settings, size: 16)),
            Tab(text: 'Advanced', icon: Icon(Icons.tune, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicTab(),
          _buildSettingsTab(),
          _buildAdvancedTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Cancel', style: GoogleFonts.inter()),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Create Room',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Name
          _buildSectionTitle('Room Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'Enter room name',
            icon: Icons.meeting_room,
          ),
          
          SizedBox(height: 24),
          
          // Description
          _buildSectionTitle('Description'),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe your room...',
            icon: Icons.description,
            maxLines: 3,
          ),
          
          SizedBox(height: 24),
          
          // Room Type
          _buildSectionTitle('Room Type'),
          _buildRoomTypeSelector(),
          
          SizedBox(height: 24),
          
          // Category
          _buildSectionTitle('Category'),
          _buildCategorySelector(),
          
          SizedBox(height: 24),
          
          // Max Participants
          _buildSectionTitle('Maximum Participants'),
          _buildParticipantSlider(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password Protection
          _buildSectionTitle('Security'),
          _buildPasswordSection(),
          
          SizedBox(height: 24),
          
          // Scheduling
          _buildSectionTitle('Scheduling'),
          _buildSchedulingSection(),
          
          SizedBox(height: 24),
          
          // Features
          _buildSectionTitle('Room Features'),
          _buildFeaturesSection(),
          
          SizedBox(height: 24),
          
          // Tags
          _buildSectionTitle('Tags'),
          _buildTagsSection(),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moderation
          _buildSectionTitle('Moderation'),
          _buildModerationSection(),
          
          SizedBox(height: 24),
          
          // Background Music
          _buildSectionTitle('Background Music'),
          _buildMusicSection(),
          
          SizedBox(height: 24),
          
          // Room Permissions
          _buildSectionTitle('Permissions'),
          _buildPermissionsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white60),
          prefixIcon: Icon(icon, color: Color(0xFF03DAC6)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildRoomTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: RoomType.values.map((type) {
          return RadioListTile<RoomType>(
            title: Text(
              _getRoomTypeDisplayName(type),
              style: GoogleFonts.inter(color: Colors.white),
            ),
            subtitle: Text(
              _getRoomTypeDescription(type),
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
            ),
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                if (value == RoomType.scheduled) {
                  _scheduledTime = DateTime.now().add(Duration(hours: 1));
                }
              });
            },
            activeColor: Color(0xFF03DAC6),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 120,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: RoomCategory.values.length,
        itemBuilder: (context, index) {
          final category = RoomCategory.values[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Color(0xFF1976D2).withOpacity(0.3) 
                    : Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Color(0xFF1976D2) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: isSelected ? Color(0xFF03DAC6) : Colors.white60,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getCategoryDisplayName(category),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Color(0xFF03DAC6) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantSlider() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participants',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              Text(
                '$_maxParticipants',
                style: GoogleFonts.inter(
                  color: Color(0xFF03DAC6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: Color(0xFF03DAC6),
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() => _maxParticipants = value.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Password Protection',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            subtitle: Text(
              'Require password to join',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
            ),
            value: _isPasswordProtected,
            onChanged: (value) {
              setState(() => _isPasswordProtected = value);
            },
            activeColor: Color(0xFF03DAC6),
          ),
          if (_isPasswordProtected) ...[
            Divider(color: Colors.white.withOpacity(0.1)),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: GoogleFonts.inter(color: Colors.white60),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF03DAC6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF03DAC6), width: 2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulingSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_selectedType == RoomType.scheduled) ...[
            ListTile(
              leading: Icon(Icons.schedule, color: Color(0xFF03DAC6)),
              title: Text(
                'Scheduled Time',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                _scheduledTime?.toString() ?? 'Not set',
                style: GoogleFonts.inter(color: Colors.white60),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
              onTap: _selectDateTime,
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
          ],
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Duration',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    Text(
                      '$_estimatedDuration min',
                      style: GoogleFonts.inter(
                        color: Color(0xFF03DAC6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _estimatedDuration.toDouble(),
                  min: 15,
                  max: 240,
                  divisions: 15,
                  activeColor: Color(0xFF03DAC6),
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setState(() => _estimatedDuration = value.round());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Recording', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text('Enable session recording', style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
            value: _isRecordingEnabled,
            onChanged: (value) => setState(() => _isRecordingEnabled = value),
            activeColor: Color(0xFF03DAC6),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          SwitchListTile(
            title: Text('Live Transcription', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text('Real-time speech-to-text', style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
            value: _isTranscriptionEnabled,
            onChanged: (value) => setState(() => _isTranscriptionEnabled = value),
            activeColor: Color(0xFF03DAC6),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _tagsController,
          hint: 'Add tags (separated by commas)',
          icon: Icons.tag,
        ),
        if (_tags.isNotEmpty) ...[
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag, style: GoogleFonts.inter(fontSize: 12)),
              deleteIcon: Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _tags.remove(tag));
              },
              backgroundColor: Color(0xFF1976D2).withOpacity(0.2),
              deleteIconColor: Colors.white,
              labelStyle: GoogleFonts.inter(color: Colors.white),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildModerationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Speaking Time Limit',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    Text(
                      _speakingTimeLimit == 0 ? 'No limit' : '$_speakingTimeLimit min',
                      style: GoogleFonts.inter(
                        color: Color(0xFF03DAC6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _speakingTimeLimit.toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 6,
                  activeColor: Color(0xFF03DAC6),
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setState(() => _speakingTimeLimit = value.round());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSection() {
    final musicOptions = [
      'None',
      'Ambient Forest',
      'Ocean Waves',
      'Rain Sounds',
      'Cafe Ambience',
      'Soft Piano',
      'White Noise'
    ];

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: musicOptions.map((music) {
          final isSelected = _backgroundMusic == music || 
                           (_backgroundMusic == null && music == 'None');
          
          return RadioListTile<String?>(
            title: Text(music, style: GoogleFonts.inter(color: Colors.white)),
            value: music == 'None' ? null : music,
            groupValue: _backgroundMusic,
            onChanged: (value) {
              setState(() => _backgroundMusic = value);
            },
            activeColor: Color(0xFF03DAC6),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Screen Sharing', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text('Allow participants to share screens', style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
            value: _allowScreenSharing,
            onChanged: (value) => setState(() => _allowScreenSharing = value),
            activeColor: Color(0xFF03DAC6),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          SwitchListTile(
            title: Text('Reactions', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text('Allow emoji reactions and applause', style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
            value: _allowReactions,
            onChanged: (value) => setState(() => _allowReactions = value),
            activeColor: Color(0xFF03DAC6),
          ),
        ],
      ),
    );
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledTime ?? DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledTime ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createRoom() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a room name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_isPasswordProtected && _passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Parse tags
    if (_tagsController.text.trim().isNotEmpty) {
      _tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    final room = EnhancedRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      ownerId: 'current_user_id', // This would be the actual user ID
      maxParticipants: _maxParticipants,
      isPasswordProtected: _isPasswordProtected,
      password: _isPasswordProtected ? _passwordController.text.trim() : null,
      scheduledTime: _scheduledTime,
      estimatedDuration: _estimatedDuration,
      tags: _tags,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      isRecordingEnabled: _isRecordingEnabled,
      isTranscriptionEnabled: _isTranscriptionEnabled,
      backgroundMusic: _backgroundMusic,
      allowScreenSharing: _allowScreenSharing,
      allowReactions: _allowReactions,
      speakingTimeLimit: _speakingTimeLimit,
    );

    try {
      await RoomService.createRoom(
        roomName: room.name,
        description: room.description,
        isPrivate: room.isPasswordProtected ||
            room.type.toString().split('.').last == 'private',
      );
    } catch (error) {
      Get.snackbar('Could not create room', error.toString());
      return;
    }

    Get.back(result: room);
    Get.snackbar(
      'Success',
      'Room "${room.name}" created successfully!',
      backgroundColor: Color(0xFF03DAC6),
      colorText: Colors.black,
    );
  }

  void _showHelpDialog() {
    Get.defaultDialog(
      title: 'Room Creation Help',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏠 Basic: Set name, description, type and category'),
          SizedBox(height: 8),
          Text('⚙️ Settings: Configure security, scheduling and features'),
          SizedBox(height: 8),
          Text('🔧 Advanced: Set up moderation, music and permissions'),
        ],
      ),
      textConfirm: 'Got it',
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF1976D2),
      onConfirm: () => Get.back(),
    );
  }

  String _getRoomTypeDisplayName(RoomType type) {
    switch (type) {
      case RoomType.public:
        return 'Public Room';
      case RoomType.private:
        return 'Private Room';
      case RoomType.scheduled:
        return 'Scheduled Room';
      case RoomType.moderated:
        return 'Moderated Room';
    }
  }

  String _getRoomTypeDescription(RoomType type) {
    switch (type) {
      case RoomType.public:
        return 'Anyone can join';
      case RoomType.private:
        return 'Invite only';
      case RoomType.scheduled:
        return 'Starts at specific time';
      case RoomType.moderated:
        return 'Requires permission to speak';
    }
  }

  IconData _getCategoryIcon(RoomCategory category) {
    switch (category) {
      case RoomCategory.general:
        return Icons.chat;
      case RoomCategory.music:
        return Icons.music_note;
      case RoomCategory.education:
        return Icons.school;
      case RoomCategory.business:
        return Icons.business;
      case RoomCategory.gaming:
        return Icons.sports_esports;
      case RoomCategory.technology:
        return Icons.computer;
      case RoomCategory.health:
        return Icons.favorite;
      case RoomCategory.entertainment:
        return Icons.movie;
      case RoomCategory.news:
        return Icons.newspaper;
      case RoomCategory.language:
        return Icons.translate;
    }
  }

  String _getCategoryDisplayName(RoomCategory category) {
    switch (category) {
      case RoomCategory.general:
        return 'General';
      case RoomCategory.music:
        return 'Music';
      case RoomCategory.education:
        return 'Education';
      case RoomCategory.business:
        return 'Business';
      case RoomCategory.gaming:
        return 'Gaming';
      case RoomCategory.technology:
        return 'Technology';
      case RoomCategory.health:
        return 'Health';
      case RoomCategory.entertainment:
        return 'Entertainment';
      case RoomCategory.news:
        return 'News';
      case RoomCategory.language:
        return 'Language';
    }
  }
}