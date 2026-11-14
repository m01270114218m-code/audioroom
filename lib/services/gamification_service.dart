import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum BadgeType {
  // Participation badges
  firstRoom,
  socialBug, // Join 10 rooms
  partyAnimal, // Join 50 rooms
  ninja, // Join 100 rooms
  
  // Speaking badges
  firstSpeak,
  chatterBox, // Speak for 1 hour total
  orator, // Speak for 10 hours total
  speechMaster, // Speak for 100 hours total
  
  // Room creation badges
  roomMaker, // Create first room
  hostMaster, // Host 10 rooms
  communityBuilder, // Host 50 rooms
  
  // Special badges
  earlyBird, // Join room before 9 AM
  nightOwl, // Join room after 11 PM
  weekendWarrior, // Active on weekends
  consistent, // Active 7 days in a row
  helpful, // Help others frequently
  mentor, // Guide new users
  
  // Category specific badges
  musicLover, // Join 20 music rooms
  techGuru, // Join 20 tech rooms
  learner, // Join 20 education rooms
  gamer, // Join 20 gaming rooms
  
  // Achievement badges
  influencer, // Have 100+ followers
  trendsetter, // Create trending rooms
  loyal, // 30 days of activity
  pioneer, // Beta tester
}

enum Achievement {
  // Daily achievements
  dailyVisitor,
  roomHopper, // Join 5 rooms in a day
  socializer, // Speak in 3 rooms in a day
  
  // Weekly achievements  
  weeklyChampion,
  conversationalist, // Speak 10 hours in a week
  networkBuilder, // Meet 20 new people in a week
  
  // Monthly achievements
  monthlyLegend,
  communityPillar, // Help 50 people in a month
  contentCreator, // Create 10 rooms in a month
  
  // Special achievements
  comeback, // Return after 30 days
  explorer, // Visit all room categories
  ambassador, // Invite 10 friends
  innovator, // Use new features first
}

class UserStats {
  int totalRoomsJoined;
  int totalSpeakingTimeMinutes;
  int totalRoomsCreated;
  int totalPeopleHelped;
  int currentStreak;
  int longestStreak;
  DateTime lastActive;
  Map<String, int> categoryStats; // category -> count
  Set<String> earnedBadges;
  Set<String> earnedAchievements;
  int level;
  int experiencePoints;
  int totalFollowers;
  DateTime joinDate;

  UserStats({
    this.totalRoomsJoined = 0,
    this.totalSpeakingTimeMinutes = 0,
    this.totalRoomsCreated = 0,
    this.totalPeopleHelped = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastActive,
    Map<String, int>? categoryStats,
    Set<String>? earnedBadges,
    Set<String>? earnedAchievements,
    this.level = 1,
    this.experiencePoints = 0,
    this.totalFollowers = 0,
    DateTime? joinDate,
  }) : 
    lastActive = lastActive ?? DateTime.now(),
    categoryStats = categoryStats ?? {},
    earnedBadges = earnedBadges ?? {},
    earnedAchievements = earnedAchievements ?? {},
    joinDate = joinDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'totalRoomsJoined': totalRoomsJoined,
      'totalSpeakingTimeMinutes': totalSpeakingTimeMinutes,
      'totalRoomsCreated': totalRoomsCreated,
      'totalPeopleHelped': totalPeopleHelped,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActive': lastActive.toIso8601String(),
      'categoryStats': categoryStats,
      'earnedBadges': earnedBadges.toList(),
      'earnedAchievements': earnedAchievements.toList(),
      'level': level,
      'experiencePoints': experiencePoints,
      'totalFollowers': totalFollowers,
      'joinDate': joinDate.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalRoomsJoined: json['totalRoomsJoined'] ?? 0,
      totalSpeakingTimeMinutes: json['totalSpeakingTimeMinutes'] ?? 0,
      totalRoomsCreated: json['totalRoomsCreated'] ?? 0,
      totalPeopleHelped: json['totalPeopleHelped'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      categoryStats: Map<String, int>.from(json['categoryStats'] ?? {}),
      earnedBadges: Set<String>.from(json['earnedBadges'] ?? []),
      earnedAchievements: Set<String>.from(json['earnedAchievements'] ?? []),
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
      totalFollowers: json['totalFollowers'] ?? 0,
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class GamificationService {
  static const String _userStatsKey = 'user_stats';
  static const String _leaderboardKey = 'leaderboard';
  static UserStats? _currentUserStats;

  /// Initialize gamification service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_userStatsKey);
    
    if (statsJson != null) {
      _currentUserStats = UserStats.fromJson(json.decode(statsJson));
    } else {
      _currentUserStats = UserStats();
      await _saveUserStats();
    }
    
    await _updateDailyStreak();
  }

  /// Get current user stats
  static UserStats get currentUserStats => _currentUserStats ?? UserStats();

  /// Award experience points and check for level up
  static Future<bool> awardExperience(int points) async {
    if (_currentUserStats == null) return false;
    
    final oldLevel = _currentUserStats!.level;
    _currentUserStats!.experiencePoints += points;
    
    // Calculate new level (exponential progression)
    final newLevel = _calculateLevel(_currentUserStats!.experiencePoints);
    _currentUserStats!.level = newLevel;
    
    await _saveUserStats();
    
    return newLevel > oldLevel; // Return true if leveled up
  }

  /// Track room joined
  static Future<List<String>> trackRoomJoined(String category) async {
    if (_currentUserStats == null) return [];
    
    _currentUserStats!.totalRoomsJoined++;
    _currentUserStats!.categoryStats[category] = 
        (_currentUserStats!.categoryStats[category] ?? 0) + 1;
    
    // Award experience
    await awardExperience(10);
    
    // Check for new badges and achievements
    final newRewards = await _checkForNewRewards();
    
    await _saveUserStats();
    return newRewards;
  }

  /// Track speaking time
  static Future<List<String>> trackSpeakingTime(int minutes) async {
    if (_currentUserStats == null) return [];
    
    _currentUserStats!.totalSpeakingTimeMinutes += minutes;
    
    // Award experience based on speaking time
    await awardExperience(minutes * 2);
    
    final newRewards = await _checkForNewRewards();
    
    await _saveUserStats();
    return newRewards;
  }

  /// Track room created
  static Future<List<String>> trackRoomCreated() async {
    if (_currentUserStats == null) return [];
    
    _currentUserStats!.totalRoomsCreated++;
    
    // Award experience
    await awardExperience(25);
    
    final newRewards = await _checkForNewRewards();
    
    await _saveUserStats();
    return newRewards;
  }

  /// Track helping others
  static Future<List<String>> trackHelpingOthers() async {
    if (_currentUserStats == null) return [];
    
    _currentUserStats!.totalPeopleHelped++;
    
    // Award experience
    await awardExperience(15);
    
    final newRewards = await _checkForNewRewards();
    
    await _saveUserStats();
    return newRewards;
  }

  /// Check for new badges and achievements
  static Future<List<String>> _checkForNewRewards() async {
    final newRewards = <String>[];
    
    // Check badges
    for (final badge in BadgeType.values) {
      if (!_currentUserStats!.earnedBadges.contains(badge.name) && 
          _checkBadgeRequirement(badge)) {
        _currentUserStats!.earnedBadges.add(badge.name);
        newRewards.add('Badge: ${getBadgeDisplayName(badge)}');
      }
    }
    
    // Check achievements
    for (final achievement in Achievement.values) {
      if (!_currentUserStats!.earnedAchievements.contains(achievement.name) && 
          _checkAchievementRequirement(achievement)) {
        _currentUserStats!.earnedAchievements.add(achievement.name);
        newRewards.add('Achievement: ${getAchievementDisplayName(achievement)}');
      }
    }
    
    return newRewards;
  }

  /// Check if badge requirement is met
  static bool _checkBadgeRequirement(BadgeType badge) {
    final stats = _currentUserStats!;
    
    switch (badge) {
      case BadgeType.firstRoom:
        return stats.totalRoomsJoined >= 1;
      case BadgeType.socialBug:
        return stats.totalRoomsJoined >= 10;
      case BadgeType.partyAnimal:
        return stats.totalRoomsJoined >= 50;
      case BadgeType.ninja:
        return stats.totalRoomsJoined >= 100;
        
      case BadgeType.firstSpeak:
        return stats.totalSpeakingTimeMinutes >= 1;
      case BadgeType.chatterBox:
        return stats.totalSpeakingTimeMinutes >= 60;
      case BadgeType.orator:
        return stats.totalSpeakingTimeMinutes >= 600;
      case BadgeType.speechMaster:
        return stats.totalSpeakingTimeMinutes >= 6000;
        
      case BadgeType.roomMaker:
        return stats.totalRoomsCreated >= 1;
      case BadgeType.hostMaster:
        return stats.totalRoomsCreated >= 10;
      case BadgeType.communityBuilder:
        return stats.totalRoomsCreated >= 50;
        
      case BadgeType.helpful:
        return stats.totalPeopleHelped >= 10;
      case BadgeType.mentor:
        return stats.totalPeopleHelped >= 50;
        
      case BadgeType.musicLover:
        return (stats.categoryStats['music'] ?? 0) >= 20;
      case BadgeType.techGuru:
        return (stats.categoryStats['technology'] ?? 0) >= 20;
      case BadgeType.learner:
        return (stats.categoryStats['education'] ?? 0) >= 20;
      case BadgeType.gamer:
        return (stats.categoryStats['gaming'] ?? 0) >= 20;
        
      case BadgeType.consistent:
        return stats.currentStreak >= 7;
      case BadgeType.loyal:
        return DateTime.now().difference(stats.joinDate).inDays >= 30;
        
      default:
        return false;
    }
  }

  /// Check if achievement requirement is met
  static bool _checkAchievementRequirement(Achievement achievement) {
    // This would check for daily/weekly/monthly achievements
    // Implementation depends on tracking daily activities
    return false; // Simplified for now
  }

  /// Calculate level based on experience points
  static int _calculateLevel(int exp) {
    // Level 1: 0-99 XP, Level 2: 100-299 XP, Level 3: 300-599 XP, etc.
    // Formula: level = floor(sqrt(exp/50)) + 1
    return (math.sqrt(exp / 50).floor()) + 1;
  }

  /// Get experience needed for next level
  static int getExperienceForNextLevel() {
    final currentLevel = _currentUserStats?.level ?? 1;
    final nextLevel = currentLevel + 1;
    final expForNextLevel = (nextLevel - 1) * (nextLevel - 1) * 50;
    return expForNextLevel;
  }

  /// Update daily streak
  static Future<void> _updateDailyStreak() async {
    if (_currentUserStats == null) return;
    
    final now = DateTime.now();
    final lastActive = _currentUserStats!.lastActive;
    final daysDifference = now.difference(lastActive).inDays;
    
    if (daysDifference == 0) {
      // Same day, no change
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      _currentUserStats!.currentStreak++;
      if (_currentUserStats!.currentStreak > _currentUserStats!.longestStreak) {
        _currentUserStats!.longestStreak = _currentUserStats!.currentStreak;
      }
    } else {
      // Missed days, reset streak
      _currentUserStats!.currentStreak = 1;
    }
    
    _currentUserStats!.lastActive = now;
    await _saveUserStats();
  }

  /// Get leaderboard
  static Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    // This would fetch from a server in a real app
    // For demo, return mock data
    return [
      LeaderboardEntry('NinjaUser1', 2500, 15, 'assets/avatars/ninja1.png'),
      LeaderboardEntry('SoundMaster', 2200, 14, 'assets/avatars/sound.png'),
      LeaderboardEntry('VoiceGuru', 1800, 12, 'assets/avatars/voice.png'),
      LeaderboardEntry('ChatChampion', 1500, 11, 'assets/avatars/chat.png'),
      LeaderboardEntry('AudioNinja', 1200, 10, 'assets/avatars/audio.png'),
    ];
  }

  /// Get badge display name
  static String getBadgeDisplayName(BadgeType badge) {
    switch (badge) {
      case BadgeType.firstRoom:
        return 'First Room';
      case BadgeType.socialBug:
        return 'Social Bug';
      case BadgeType.partyAnimal:
        return 'Party Animal';
      case BadgeType.ninja:
        return 'Audio Ninja';
      case BadgeType.firstSpeak:
        return 'First Words';
      case BadgeType.chatterBox:
        return 'Chatter Box';
      case BadgeType.orator:
        return 'Great Orator';
      case BadgeType.speechMaster:
        return 'Speech Master';
      case BadgeType.roomMaker:
        return 'Room Maker';
      case BadgeType.hostMaster:
        return 'Host Master';
      case BadgeType.communityBuilder:
        return 'Community Builder';
      case BadgeType.helpful:
        return 'Helpful Soul';
      case BadgeType.mentor:
        return 'Mentor';
      case BadgeType.musicLover:
        return 'Music Lover';
      case BadgeType.techGuru:
        return 'Tech Guru';
      case BadgeType.learner:
        return 'Eager Learner';
      case BadgeType.gamer:
        return 'Gaming Expert';
      case BadgeType.consistent:
        return 'Consistent User';
      case BadgeType.loyal:
        return 'Loyal Member';
      case BadgeType.earlyBird:
        return 'Early Bird';
      case BadgeType.nightOwl:
        return 'Night Owl';
      case BadgeType.weekendWarrior:
        return 'Weekend Warrior';
      case BadgeType.influencer:
        return 'Influencer';
      case BadgeType.trendsetter:
        return 'Trendsetter';
      case BadgeType.pioneer:
        return 'Pioneer';
    }
  }

  /// Get achievement display name
  static String getAchievementDisplayName(Achievement achievement) {
    switch (achievement) {
      case Achievement.dailyVisitor:
        return 'Daily Visitor';
      case Achievement.roomHopper:
        return 'Room Hopper';
      case Achievement.socializer:
        return 'Socializer';
      case Achievement.weeklyChampion:
        return 'Weekly Champion';
      case Achievement.conversationalist:
        return 'Conversationalist';
      case Achievement.networkBuilder:
        return 'Network Builder';
      case Achievement.monthlyLegend:
        return 'Monthly Legend';
      case Achievement.communityPillar:
        return 'Community Pillar';
      case Achievement.contentCreator:
        return 'Content Creator';
      case Achievement.comeback:
        return 'Welcome Back';
      case Achievement.explorer:
        return 'Explorer';
      case Achievement.ambassador:
        return 'Ambassador';
      case Achievement.innovator:
        return 'Innovator';
    }
  }

  /// Get badge icon
  static IconData getBadgeIcon(BadgeType badge) {
    switch (badge) {
      case BadgeType.firstRoom:
        return Icons.room;
      case BadgeType.socialBug:
        return Icons.group;
      case BadgeType.partyAnimal:
        return Icons.celebration;
      case BadgeType.ninja:
        return Icons.flash_on;
      case BadgeType.firstSpeak:
        return Icons.record_voice_over;
      case BadgeType.chatterBox:
        return Icons.chat_bubble;
      case BadgeType.orator:
        return Icons.mic;
      case BadgeType.speechMaster:
        return Icons.campaign;
      case BadgeType.roomMaker:
        return Icons.add_circle;
      case BadgeType.hostMaster:
        return Icons.person;
      case BadgeType.communityBuilder:
        return Icons.business;
      case BadgeType.helpful:
        return Icons.help;
      case BadgeType.mentor:
        return Icons.school;
      case BadgeType.musicLover:
        return Icons.music_note;
      case BadgeType.techGuru:
        return Icons.computer;
      case BadgeType.learner:
        return Icons.book;
      case BadgeType.gamer:
        return Icons.sports_esports;
      case BadgeType.consistent:
        return Icons.trending_up;
      case BadgeType.loyal:
        return Icons.favorite;
      default:
        return Icons.star;
    }
  }

  /// Save user stats
  static Future<void> _saveUserStats() async {
    if (_currentUserStats == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, json.encode(_currentUserStats!.toJson()));
  }
}

class LeaderboardEntry {
  final String username;
  final int experiencePoints;
  final int level;
  final String avatarUrl;

  LeaderboardEntry(this.username, this.experiencePoints, this.level, this.avatarUrl);
}