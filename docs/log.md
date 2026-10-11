Changed 104 dependencies!
25 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Launching lib\main.dart on Chrome in debug mode...
Error: unable to find directory entry in pubspec.yaml: D:\PROJECT\vfroom\mobile\assets\images\
Error: unable to find directory entry in pubspec.yaml: D:\PROJECT\vfroom\mobile\assets\icons\
lib/widgets/gradient_button.dart:2:8: Error: Error when reading 'lib/constants/app_colors.dart': The system
cannot find the path specified
import '../constants/app_colors.dart';
       ^
lib/widgets/prompt_input_bar.dart:2:8: Error: Error when reading 'lib/constants/app_colors.dart': The system     
cannot find the path specified
import '../constants/app_colors.dart';
       ^
lib/widgets/wardrobe_selector.dart:2:8: Error: Error when reading 'lib/constants/app_colors.dart': The system
cannot find the path specified
import '../constants/app_colors.dart';
       ^
lib/widgets/gradient_button.dart:45:19: Error: The getter 'AppColors' isn't defined for the type
'GradientButton'.
 - 'GradientButton' is from 'package:vfroom_mobile/widgets/gradient_button.dart'
 ('lib/widgets/gradient_button.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
        gradient: AppColors.sunsetGradient,
                  ^^^^^^^^^
lib/widgets/gradient_button.dart:49:20: Error: The getter 'AppColors' isn't defined for the type
'GradientButton'.
 - 'GradientButton' is from 'package:vfroom_mobile/widgets/gradient_button.dart'
 ('lib/widgets/gradient_button.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
            color: AppColors.primaryOrange.withOpacity(0.35),
                   ^^^^^^^^^
lib/widgets/prompt_input_bar.dart:34:63: Error: Not a constant expression.
            icon: const Icon(Icons.add_circle_outline, color: AppColors.slateGrey),
                                                              ^^^^^^^^^
lib/widgets/prompt_input_bar.dart:42:45: Error: Not a constant expression.
                hintStyle: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
                                            ^^^^^^^^^
lib/widgets/prompt_input_bar.dart:50:25: Error: The getter 'AppColors' isn't defined for the type
'PromptInputBar'.
 - 'PromptInputBar' is from 'package:vfroom_mobile/widgets/prompt_input_bar.dart'
 ('lib/widgets/prompt_input_bar.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
              gradient: AppColors.sunsetGradient,
                        ^^^^^^^^^
lib/widgets/wardrobe_selector.dart:33:37: Error: The getter 'AppColors' isn't defined for the type
'WardrobeSelector'.
 - 'WardrobeSelector' is from 'package:vfroom_mobile/widgets/wardrobe_selector.dart'
 ('lib/widgets/wardrobe_selector.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
                color: isSelected ? AppColors.primaryOrange : Colors.white,
                                    ^^^^^^^^^
lib/widgets/wardrobe_selector.dart:36:39: Error: The getter 'AppColors' isn't defined for the type
'WardrobeSelector'.
 - 'WardrobeSelector' is from 'package:vfroom_mobile/widgets/wardrobe_selector.dart'
 ('lib/widgets/wardrobe_selector.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
                  color: isSelected ? AppColors.primaryOrange : Colors.black.withOpacity(0.06),
                                      ^^^^^^^^^
lib/widgets/wardrobe_selector.dart:42:34: Error: The getter 'AppColors' isn't defined for the type
'WardrobeSelector'.
 - 'WardrobeSelector' is from 'package:vfroom_mobile/widgets/wardrobe_selector.dart'
 ('lib/widgets/wardrobe_selector.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
                          color: AppColors.primaryOrange.withOpacity(0.3),
                                 ^^^^^^^^^
 - 'WardrobeSelector' is from 'package:vfroom_mobile/widgets/wardrobe_selector.dart'
 ('lib/widgets/wardrobe_selector.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
                          color: AppColors.primaryOrange.withOpacity(0.3),
                                 ^^^^^^^^^
                          color: AppColors.primaryOrange.withOpacity(0.3),
                                 ^^^^^^^^^
lib/widgets/wardrobe_selector.dart:53:56: Error: The getter 'AppColors' isn't defined for the type
'WardrobeSelector'.
 - 'WardrobeSelector' is from 'package:vfroom_mobile/widgets/wardrobe_selector.dart'
 ('lib/widgets/wardrobe_selector.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'AppColors'.      
                    color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                                                       ^^^^^^^^^
Waiting for connection from debug service on Chrome...            214.5s
Failed to compile application.