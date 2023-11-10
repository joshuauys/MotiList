// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

// A single leaderboard item representing each user's data.
class LeaderboardItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int points;

  const LeaderboardItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          // The circular image.
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 30.0, // You can adjust the size of the avatar as required.
          ),
          const SizedBox(
              width: 15.0), // Some spacing between the picture and the text.
          // User's name and points.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18.0, // Adjust your size as needed.
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$points pts',
                  style: TextStyle(
                    fontSize: 16.0, // Adjust your size as needed.
                    color: Colors.grey[
                        600], // You can choose the appropriate color for your design.
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// The entire leaderboard widget.
class Leaderboard extends StatelessWidget {
  final List<LeaderboardItem> items;

  const Leaderboard({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }
}
