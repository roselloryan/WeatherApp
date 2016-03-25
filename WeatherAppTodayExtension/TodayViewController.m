//
// TodayViewController.m


#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreLocation/CoreLocation.h>
#import "UserCurrentLocation.h"
#import "ExtensionAPIClient.h"
#import "CurrentCityWeather.h"


@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UserCurrentLocation *userCurrentLocation;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSString *locationString;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *iconID;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) NSString *tempString;

@property (strong, nonatomic) CurrentCityWeather *currentCityWeather;




@property (assign, nonatomic) BOOL didUpdateSinceViewDidLoad;

@end


@implementation TodayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.didUpdateSinceViewDidLoad = NO;
    // request auth for location service and startUpdating if allowed
    //set up location manager and delegate
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

}


#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LocactionManager Error: %@", error);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    CLLocation *currentLocation =[locations lastObject];
    
    if(locations) {
        
        // self.userCurrentLocation to be used for widgetbackground updates in future
        self.userCurrentLocation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        
        NSLog(@"LAT: %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        NSLog(@"LON: %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        
        [ExtensionAPIClient getWeatherForCurrentLocation:currentLocation withCompletionBlock:^(NSDictionary *responseDictionary) {
            
            CurrentCityWeather *currentCityWeather = [[CurrentCityWeather alloc]initWithResponseDictionary:responseDictionary];
            self.currentCityWeather = currentCityWeather;
            
            [ExtensionAPIClient getIconImageForIconID:self.currentCityWeather.iconID withCompletionBlock:^(UIImage *iconImage) {
               
                self.currentCityWeather.iconImage = iconImage;
                
                [self updateInfoOnMainThread];
            }];
        }];
    }
    
    [self.locationManager stopUpdatingLocation];
}

-(void)updateInfoOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.iconImageView.image = self.currentCityWeather.iconImage;
        self.locationLabel.text = self.currentCityWeather.cityName;
        self.tempLabel.text = self.currentCityWeather.tempInCelsiusAndFahrenheit;
    });
}

//-(void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
//
// use lastUpdateAttempt to test for if call should be made or undate successful???
//
////    [ExtensionAPIClient getWeatherForCurrentLocation:(CLLocation *) withCompletionBlock:^(NSDictionary *responseDictionary) {
////        // stuff
////    }]
//    
//}


//removes bottom padding.
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    NSLog(@"WHEN IS THIS CALLED?????????????before?????????????????");
    UIEdgeInsets insetsToRemoveBottomPadding = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0, defaultMarginInsets.left );
    NSLog(@"WHEN IS THIS CALLED??????????????after????????????????");
    return insetsToRemoveBottomPadding;
}


@end
