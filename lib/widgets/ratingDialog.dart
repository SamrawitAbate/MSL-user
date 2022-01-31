// ignore_for_file: file_names

import 'package:user/widgets/ratingBarView.dart';
import 'package:flutter/material.dart';

popUpRating(BuildContext context, String id) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RatingBarCustom(to: id,)
        );
      });
}
