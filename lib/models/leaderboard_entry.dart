class LeaderboardEntry {
  late String username;
  late int points;

  LeaderboardEntry({required this.username, required this.points});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'points': points,
    };
  }

  // Convert from map
  static LeaderboardEntry fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      username: map['username'],
      points: map['points'],
    );
  }

}