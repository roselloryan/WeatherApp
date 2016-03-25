//
//  AddCityViewController.h


#import <UIKit/UIKit.h>
#import "WeatherAppTableViewController.h"


@interface AddCityViewController : UIViewController

@property (strong, nonatomic) NSArray *allCitiesArray;
@property (strong, nonatomic) NSMutableArray *possibleCitiesArrayOfMKAnnotations;
@end
