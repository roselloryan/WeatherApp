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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tempLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tempLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationLabelLeadingConstraint;

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

    
    // catch if iPhone running iOS 10+
    if ([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) { // iOS 10+
        
        NSLog(@"POST POST POST POST (setWidgetLargestAvailableDisplayMode)");
        
        // Adjust constraints for iOS 10+
        self.iconImageViewLeadingConstraint.constant = 20;
        self.tempLabelTrailingConstraint.constant = -28;
        self.iconImageViewHeightConstraint.constant = -40;
        self.locationLabel.font = [UIFont systemFontOfSize:22.0];
        self.tempLabel.font = [UIFont systemFontOfSize:22.0];
        self.tempLabel.numberOfLines = 2;
        self.tempLabelHeightConstraint.constant = 60;
        self.locationLabel.textColor = [UIColor blackColor];
        self.tempLabel.textColor = [UIColor blackColor];
        
    } else {
        // Let widgetMarginInsetsForProposedMarginInsets: handle appearance
        NSLog(@"PRE PRE PRE PRE PRE (setWidgetLargestAvailableDisplayMode)");
    }

//    if ([self.extensionContext respondsToSelector:@selector(widgetMarginInsetsForProposedMarginInsets:)]) {
//        
//        NSLog(@"PRE PRE PRE PRE PRE (widgetMarginInsetsForProposedMarginInsets:)");
//        
//    } else {
//        NSLog(@"POST POST POST POST (widgetMarginInsetsForProposedMarginInsets:)");
//    }

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
        
        if ([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) {
            self.tempLabel.text = [self.tempLabel.text stringByReplacingOccurrencesOfString:@" / " withString:@"\n"];
        }
    });
}


////removes bottom padding for iOS pre 10.0
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    NSLog(@"WHEN IS THIS CALLED??????????????????????");
    UIEdgeInsets insetsToRemoveBottomPadding = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0, defaultMarginInsets.left);

    [self.view bringSubviewToFront:self.clearLabel];
    
    NSLog(@"insets: %@", NSStringFromUIEdgeInsets(insetsToRemoveBottomPadding));
    
    return insetsToRemoveBottomPadding;
}



@end
