import 'package:flutter/material.dart';
class SliderProvider extends ChangeNotifier{
  double sliderSpeed;
  SliderProvider({
    this.sliderSpeed = 0.7,
  });

  void changeSpeed({
    required double newSliderSpeed,
  }) async{
    sliderSpeed = newSliderSpeed;
    notifyListeners();
  }
}