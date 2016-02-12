
#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreLocation/CoreLocation.h>
#import "UserCurrentLocation.h"
#import "ExtensionAPIClient.h"


@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UserCurrentLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end


@implementation TodayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //set up location manager and delegate
//    self.locationManager = [[CLLocationManager alloc]init];
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    NSLog(@"In Extension ViewDidLoad");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // request auth for location service and startUpdating if allowed
    //set up location manager and delegate
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"In viewWillAppear");
}


#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@", locations);
    NSLog(@"Last CLLocation object in array: %@", [locations lastObject]);
    CLLocation *currentLocation =[locations lastObject];
    
    if(locations != nil) {
        NSLog(@"LAT: %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        NSLog(@"LON: %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        
        [ExtensionAPIClient getWeatherForCurrentLocation:currentLocation withCompletionBlock:^(NSDictionary *responseDictionary) {
            
            [ExtensionAPIClient getIconImageForIconID:responseDictionary[@"weather"][0][@"icon"] withCompletionBlock:^(UIImage *iconImage) {
                //stuff
                
            }];
            
            // update today extension labels
            // get back on main thread to avoid error about updating from background thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationLabel.text = responseDictionary[@"name"];
                CGFloat tempInCelsius = [responseDictionary[@"main"][@"temp"] floatValue] -273.15;
                CGFloat tempInFahrenheit = (tempInCelsius * 9/5) + 32;
                NSString *tempString = [NSString stringWithFormat:@"%.0f°C / %.0f°F", roundf(tempInCelsius), roundf(tempInFahrenheit)];
                self.tempLabel.text = tempString;
            });
        }];
    }
    [self.locationManager stopUpdatingLocation];
}

//removes bottom padding.
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    UIEdgeInsets insetsToRemoveBottomPadding = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0,defaultMarginInsets.right );
    
    return insetsToRemoveBottomPadding;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
//    // Perform any setup necessary in order to update the view.
//    
//        NSLog(@"Whathe?");
//    
//    
//    if(NCUpdateResultFailed) {
//        NSLog(@"Something Else?");
//    }
//    // If an error is encountered, use NCUpdateResultFailed
//    // If there's no update required, use NCUpdateResultNoData
//    // If there's an update, use NCUpdateResultNewData
//
//    completionHandler(NCUpdateResultNewData);
//}

@end
