import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarsRating extends StatefulWidget {
  final Function(double) onRatingChanged;
  final double rating;

  const StarsRating({
    Key? key,
    required this.onRatingChanged,
    required this.rating,
  }) : super(key: key);

  @override
  _StarsRatingState createState() => _StarsRatingState();
}

class _StarsRatingState extends State<StarsRating> {
  double _ratingValue = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _averageRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _averageRating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _ratingValue = rating;
        });
        widget.onRatingChanged(rating);
      },
    );
  }
}
