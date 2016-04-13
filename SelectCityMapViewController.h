//
//  MapViewController.h


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface SelectCityMapViewController : UIViewController


@property (strong, nonatomic) NSMutableArray *possibleCitiesArrayOfMKAnnotations;
@property (strong, nonatomic) NSString *cityName;


@end
