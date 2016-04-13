//
// TodayViewController.m


#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreLocation/CoreLocation.h>
#import "UserCurrentLocation.h"
#import "ExtensionAPIClient.h"
#import "CurrentCityWeather.h"


@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UserCurrentLocation *userCurrentLocation;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSString *locationString;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) NSString *iconID;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) NSString *tempString;

@property (strong, nonatomic) UILabel *clearLabel;

@property (strong, nonatomic) CurrentCityWeather *currentCityWeather;


@end


@implementation TodayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // request auth for location service and startUpdating if allowed
    //set up location manager and delegate
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    
    //build tap gesture recognizer to open app
    self.clearLabel = [[UILabel alloc]initWithFrame: self.view.bounds];
    self.clearLabel.userInteractionEnabled = YES;
    self.clearLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.clearLabel];
    [self.view bringSubviewToFront:self.clearLabel];
    
    // add tapGestureRecognizer to open app
    UITapGestureRecognizer *openTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(launchHostingApp:)];
    [self.clearLabel addGestureRecognizer:openTapGestureRecognizer];
}


- (IBAction)launchHostingApp:(UIGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        NSURL *openURL = [NSURL URLWithString:@"RARWeatherApp://com.RAR.CelsiusAndFahrenheit"];
        [self.extensionContext openURL:openURL completionHandler:nil];
    }
}


#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LocactionManager Error: %@", error);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    CLLocation *currentLocation =[locations lastObject];
    
    if(locations) {
        
        // self.userCurrentLocation to be used for widgetbackground updates in future
        //        self.userCurrentLocation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        
        [ExtensionAPIClient getWeatherForCurrentLocation:currentLocation withCompletionBlock:^(NSDictionary *responseDictionary) {
            
            NSLog(@"response dictionary: %@", responseDictionary);
            
            // check for nil dictionary
            if (!responseDictionary) {
                
                NSLog(@"In NIL check!!!! response dictionary: %@", responseDictionary);
                self.clearLabel.textColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.6];
                self.clearLabel.text = @"      What's the temperature like outside?";
                [self.locationManager stopUpdatingLocation];
                
                return  ;
            }
            
            CurrentCityWeather *currentCityWeather = [[CurrentCityWeather alloc]initWithResponseDictionary:responseDictionary];
            self.currentCityWeather = currentCityWeather;
            
            [ExtensionAPIClient getIconImageForIconID:self.currentCityWeather.iconID withCompletionBlock:^(UIImage *iconImage) {
                    
                self.currentCityWeather.iconImage = iconImage;
                
                [self updateLabelsOnMainThread];
            }];
        }];
    }
    [self.locationManager stopUpdatingLocation];
}


-(void)updateLabelsOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.clearLabel.text = @"";
        self.iconImageView.image = self.currentCityWeather.iconImage;
        self.locationLabel.text = self.currentCityWeather.cityName;
        self.tempLabel.text = self.currentCityWeather.tempInCelsiusAndFahrenheit;
    });
}


//removes bottom padding.
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    NSLog(@"WHEN IS THIS CALLED?????????????before?????????????????");
    UIEdgeInsets insetsToRemoveBottomPadding = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0, defaultMarginInsets.left );
    NSLog(@"WHEN IS THIS CALLED??????????????after????????????????");

    [self.view bringSubviewToFront:self.clearLabel];
    
    return insetsToRemoveBottomPadding;
}


@end
