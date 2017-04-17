//
//  DetailWeatherVIewControllerViewController.h

#import <UIKit/UIKit.h>
#import "SelectedCity.h"


@interface DetailWeatherViewController : UIViewController

/** My cool comment
 
 @returns a city!
 */
@property (strong, nonatomic) SelectedCity *selectedCity;

@end
