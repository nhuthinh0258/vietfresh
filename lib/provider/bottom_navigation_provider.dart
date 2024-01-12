
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavigationNotifier extends StateNotifier<bool>{
  BottomNavigationNotifier() : super(true);

  void show(){
    state = true;
  }
  void hide(){
    state = false;
  }
}
final bottomNavigationProvider = StateNotifierProvider<BottomNavigationNotifier,bool>((ref){
  return BottomNavigationNotifier();
});