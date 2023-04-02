import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarsRating extends StatefulWidget {
  final dynamic Function(double)? onRatingChanged;
  final double rating;

  const StarsRating({
    Key? key,
    required this.onRatingChanged,
    required this.rating,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StarsRatingState createState() => _StarsRatingState();
}

class _StarsRatingState extends State<StarsRating> {
  double _ratingValue = 0;

  @override
  void initState() {
    super.initState();
    _ratingValue = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _ratingValue,
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
        widget.onRatingChanged!(rating);
      },
    );
  }
}
