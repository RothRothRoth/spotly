import 'package:flutter/material.dart';

class SpotCard extends StatelessWidget {
  final String title;
  final String image;
  final double rating;

  const SpotCard({
    super.key,
    required this.title,
    required this.image,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
