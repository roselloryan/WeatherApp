//
//  DetailWeatherVIewControllerViewController.m

#import "DetailWeatherViewController.h"
#import "APIClient.h"
#import "WeatherStyleKit.h"
#import <SceneKit/SceneKit.h>


@interface DetailWeatherViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end


@implementation DetailWeatherViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // deal with scene for particle emitter
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.sceneView];
    
    //change navigation tint
    self.navigationController.view.tintColor = [UIColor whiteColor];
    
    //set cityNameLabel with weather data
    self.cityNameLabel.text = self.selectedCity.cityName;
    [self.view bringSubviewToFront:self.cityNameLabel];
    
    // check for null weather data
    if (!self.selectedCity.tempInCelsius) {
        self.tempLabel.text = @"";
        self.cityNameLabel.text = @"You are beautiful, but we couldn't update the weather";
        self.descriptionLabel.text = @"We'll try again soon!";
    }
    else {
        
        //temperature and description labels in C° and F°
        NSString *tempString = [NSString stringWithFormat:@"%@ / %@", self.selectedCity.tempInCelsius, self.selectedCity.tempInFahrenheit];
        self.tempLabel.text = tempString;
        
        //set cityNameLabel with weather data
        self.cityNameLabel.text = self.selectedCity.cityName;
        [self.view bringSubviewToFront:self.cityNameLabel];
        
        // set description label
        [self.descriptionLabel sizeToFit];
        self.descriptionLabel.text = self.selectedCity.weatherDescription;
    }
    
    [self.view bringSubviewToFront:self.tempLabel];
    [self.view bringSubviewToFront:self.descriptionLabel];
    
    //set weather moreInfoLabel moreInfoButton
    self.moreInfoButton.layer.cornerRadius = 10.0f;
    self.moreInfoButton.layer.masksToBounds = YES;
    
    self.moreInfoLabel.hidden = YES;
    self.moreInfoLabel.layer.cornerRadius = 10.0f;
    self.moreInfoLabel.layer.masksToBounds = YES;

    // check for null weather data
    if (!self.selectedCity.tempHighInCelsius) {
        self.moreInfoLabel.text = @"Highs: a smile 😃\n Lows: picking your nose 👆👃\n Humidity: tears of joy 😂\n Pressure: to be exceptional!!! 🏆  \n Wind: may the wind be at your back 💨";
    }
    else {
        self.moreInfoLabel.text = [NSString stringWithFormat:@" Temp High: %@ / %@ \n Temp Low: %@ / %@ \n Humidity: %@ \n Atmospheric Pressure: %@%@ \n Wind Speed: %@ / %@",self.selectedCity.tempHighInCelsius, self.selectedCity.tempHighInFahrenheit,self.selectedCity.tempLowInCelsius, self.selectedCity.tempLowInFahrenheit, self.selectedCity.humidity, self.selectedCity.atmosphericPressure, [NSString stringWithFormat:@" "], self.selectedCity.windSpeedKPH, self.selectedCity.windSpeedMPH];
    }
    
    //bring touchables to front
    [self.view bringSubviewToFront:self.moreInfoButton];
    [self.view bringSubviewToFront:self.moreInfoLabel];

    [self setTextAndBackgroundColorsForIconCode];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
// trying to fix 4s image squish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (self.view.frame.size.height == 480) {
        
        NSLog(@"This is a 4s in DetailWeatherController");
        self.iconImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, 550);
    }
    
    [self setAnimatedWeatherSceneForIconCode];
    [self bringLabelsAndTouchablesToFront];
}



# pragma mark - Touchables


- (IBAction)backButtonTapped:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)moreInfoButtonTapped:(UIButton *)sender {

    self.moreInfoLabel.hidden = NO;
    [self.moreInfoLabel addGestureRecognizer:self.tapGestureRecognizer];
    self.moreInfoButton.enabled = NO;
    self.moreInfoButton.hidden = YES;
}


- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded){
        self.moreInfoLabel.hidden = YES;
        [self.moreInfoLabel removeGestureRecognizer:self.tapGestureRecognizer];
        self.moreInfoButton.enabled = YES;
        self.moreInfoButton.hidden = NO;
    }
}


-(void)bringLabelsAndTouchablesToFront {
    
    [self.view bringSubviewToFront:self.sceneView];
    [self.view bringSubviewToFront:self.tempLabel];
    [self.view bringSubviewToFront:self.descriptionLabel];
    [self.view bringSubviewToFront:self.cityNameLabel];
    [self.view bringSubviewToFront:self.moreInfoButton];
    [self.view bringSubviewToFront:self.moreInfoLabel];
    [self.view bringSubviewToFront:self.backButton];
}


# pragma mark - Main method for scene illustrations and animations


// sets animated scenes for weather icon's condition
-(void)setAnimatedWeatherSceneForIconCode {
    
    // check for weather icon code to display image
    if ([self.selectedCity.iconID isEqualToString:@"01d"]) {
        [self displayScene01d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"02d"]) {
        [self displayScene02d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"03d"]) {
        [self displayScene03d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"04d"]) {
        [self displayScene04d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"09d"]) {
        [self displayScene09d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10d"]) {
        [self displayScene10d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11d"]) {
        [self displayScene11d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13d"]) {
        [self displayScene13d];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"50d"]) {
        [self displayScene50d];
    }
    
    //nighttime canvases
    else if ([self.selectedCity.iconID isEqualToString:@"01n"]) {
        [self displayScene01n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"02n"]) {
        [self displayScene02n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"03n"]) {
        [self displayScene03n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"04n"]) {
        [self displayScene04n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"09n"]) {
        [self displayScene09n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10n"]) {
        [self displayScene10n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11n"]) {
        [self displayScene11n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13n"]) {
        [self displayScene13n];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"50n"]) {
        [self displayScene50n];
    }
    // add screen for lack of icon code or no data
    else {
        [self displaySceneForNoIconCode];
    }
}

# pragma mark - methods for individual weather scenes

-(void)displayScene01d {
    // image views to be animated
    
    // PC Canvas numbers: 2, 47, 49, 46, 48
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake( -200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas2];
    
    UIImageView *sunRaysOneImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysOneImageView.image = [WeatherStyleKit imageOfCanvas47];
    sunRaysOneImageView.alpha = 0;
    [self.view addSubview:sunRaysOneImageView];
    
    UIImageView *sunRaysTwoImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysTwoImageView.image = [WeatherStyleKit imageOfCanvas49];
    sunRaysTwoImageView.alpha = 0;
    [self.view addSubview:sunRaysTwoImageView];
    
    UIImageView *sunRaysThreeImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysThreeImageView.image = [WeatherStyleKit imageOfCanvas46];
    sunRaysThreeImageView.alpha = 0;
    [self.view addSubview:sunRaysThreeImageView];
    
    UIImageView *sunRaysFourImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysFourImageView.image = [WeatherStyleKit imageOfCanvas48];
    sunRaysFourImageView.alpha = 0;
    [self.view addSubview:sunRaysFourImageView];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
        
        [self sunRaysImageViewFlicker:sunRaysOneImageView withDelay:2.6];
        [self sunRaysImageViewFlicker:sunRaysTwoImageView withDelay:1.6];
        [self sunRaysImageViewFlicker:sunRaysThreeImageView withDelay:4.1];
        [self sunRaysImageViewFlicker:sunRaysFourImageView withDelay:0];
    }];
}

-(void)displayScene02d {
    // sun 3, left clouds 44, right clouds 45
    // PC canvas numbers: 3, 44, 45, 51, 52, 53
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas3];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas44];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas45];
    
    UIImageView *sunRaysOneImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysOneImageView.image = [WeatherStyleKit imageOfCanvas51];
    sunRaysOneImageView.alpha = 0;
    [self.view addSubview:sunRaysOneImageView];
    
    UIImageView *sunRaysTwoImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysTwoImageView.image = [WeatherStyleKit imageOfCanvas52];
    sunRaysTwoImageView.alpha = 0;
    [self.view addSubview:sunRaysTwoImageView];
    
    UIImageView *sunRaysThreeImageView = [[UIImageView alloc]initWithFrame: CGRectMake( 0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunRaysThreeImageView.image = [WeatherStyleKit imageOfCanvas53];
    sunRaysThreeImageView.alpha = 0;
    [self.view addSubview:sunRaysThreeImageView];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self sunRaysImageViewFlicker:sunRaysOneImageView withDelay:4.75];
        [self sunRaysImageViewFlicker:sunRaysTwoImageView withDelay:6];
        [self sunRaysImageViewFlicker:sunRaysThreeImageView withDelay:3.25];
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(-10, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(-15, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene03d {
    // sun 3, cloudsLeft 54, cloudsRight 55
    // PC canvas numbers: 3, 55, 54
    
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas3];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas55];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas54];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(-10, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene04d {
    // sun 56, cloudsLeft 57, cloudsRight 58
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas57];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas58];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(15, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene09d {
    // sun 56, left clouds 59, right clouds 60
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas59];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+20, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas60];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItRain];
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(0, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene10d {
    // same animations as iconID: "09d"
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas59];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas60];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItRain];
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(0, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene11d {
    // sun 56,left clouds 61, right clouds 62, left lightning 63, right lightning 64
    
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas61];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas62];
    
    UIImageView *lilghtningLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    lilghtningLeftImageView.image = [WeatherStyleKit imageOfCanvas63];
    lilghtningLeftImageView.alpha = 0;
    [self.view addSubview:lilghtningLeftImageView];
    
    UIImageView *lilghtningRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    lilghtningRightImageView.image = [WeatherStyleKit imageOfCanvas64];
    lilghtningRightImageView.alpha = 0;
    [self.view addSubview:lilghtningRightImageView];
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItRainHard];
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(0, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self animateDayTimeLightninGuysImageView:lilghtningRightImageView withDelay:4];
        [self animateDayTimeLightninGuysImageView:lilghtningLeftImageView withDelay:2.5];
    }];
}

-(void)displayScene13d {
    
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas74];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas75];
    
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItSnowInDaylight];
    }];
    
    // animate clouds in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        cloudsRightImageView.frame = CGRectMake(0, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene50d {
    // clouds left 67, clouds right 68, fogOne 69, fogTwo 70
    // image views to be animated
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-200, -200, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    sunImageView.image = [WeatherStyleKit imageOfCanvas56];
    
    UIImageView *cloudsLeftImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width-30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsLeftImageView.image = [WeatherStyleKit imageOfCanvas67];
    
    UIImageView *cloudsRightImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    cloudsRightImageView.image = [WeatherStyleKit imageOfCanvas68];
    
    // add FOG imageViews
    UIImageView *fogOneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-450, 0, 450, self.iconImageView.frame.size.height+20)];
    fogOneImageView.image = [WeatherStyleKit imageOfCanvas69];
    
    UIImageView *fogTwoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(450, 0, 450, self.iconImageView.frame.size.height+20)];
    fogTwoImageView.image = [WeatherStyleKit imageOfCanvas70];
    
    UIImageView *fogThreeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-450, 0, 450, self.iconImageView.frame.size.height+20)];
    fogThreeImageView.image = [WeatherStyleKit imageOfCanvas71];
    
    UIImageView *fogFourImageView = [[UIImageView alloc]initWithFrame:CGRectMake(450, 0, 450, self.iconImageView.frame.size.height+20)];
    fogFourImageView.image = [WeatherStyleKit imageOfCanvas72];
    
    //animate sun in from upper left position
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:sunImageView];
        
        sunImageView.frame = CGRectMake(0, 0, sunImageView.frame.size.width, sunImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    // animate clouds and fog in from right
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsRightImageView];
        [self.view addSubview:fogOneImageView];
        [self.view addSubview:fogThreeImageView];
        cloudsRightImageView.frame = CGRectMake(0, 0, cloudsRightImageView.frame.size.width, self.iconImageView.frame.size.height);
        fogOneImageView.frame = CGRectMake(-15, 0, self.iconImageView.frame.size.width+30 , self.iconImageView.frame.size.height+20);
        fogThreeImageView.frame = CGRectMake(-15, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height+20);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsLeftImageView];
        [self.view addSubview:fogTwoImageView];
        [self.view addSubview:fogFourImageView];
        cloudsLeftImageView.frame = CGRectMake(0, 0, cloudsLeftImageView.frame.size.width, self.iconImageView.frame.size.height);
        fogTwoImageView.frame = CGRectMake(-15, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height+20);
        fogFourImageView.frame = CGRectMake(-15, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height+20);
    } completion:^(BOOL finished) {
        [self floatFogImageView:fogOneImageView withDuration:6 andWithDelay:1];
        [self floatFogImageView:fogTwoImageView withDuration:5 andWithDelay:6];
        [self floatFogImageView:fogThreeImageView withDuration:4 andWithDelay:3];
        [self floatFogImageView:fogFourImageView withDuration:5 andWithDelay:0];
    }];
}

-(void)displayScene01n {
    // PC canvases 4, 22
    // image views to be animated
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas4];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas22];
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:starsImageView];
        
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene02n {
    
    // image views to be animated
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas4];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas22];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas7];
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:starsImageView];
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width+20, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene03n {
    
    // image views to be animated
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas23];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas22];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas6];
    
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:starsImageView];
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width * 1.07, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene04n {
    // clouds 1, stars 24
    // image views to be animated
    
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas24];
    
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas22];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas1];
    
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:starsImageView];
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width+20, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene09n {
    // clouds 8, stars 25, moon 26, little star 27
    // image views to be animated
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas25];
    
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    
    moonImageView.image = [WeatherStyleKit imageOfCanvas26];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas8];
    
    UIImageView *littleStarFriendImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width/4, 20, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    
    littleStarFriendImageView.image = [WeatherStyleKit imageOfCanvas27];
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:starsImageView];
        
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
        //animate little star friend to appear from behind moon
        [UIImageView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [starsImageView addSubview:littleStarFriendImageView];
            
            littleStarFriendImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        } completion:^(BOOL finished) {
        }];
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItRain];
    }];
}

-(void)displayScene10n {
    // clouds 9, stars 28, moon 26, little star 27
    
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas28];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas26];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas9];
    
    UIImageView *littleStarFriendImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width/4, 20, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    littleStarFriendImageView.image = [WeatherStyleKit imageOfCanvas27];
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:starsImageView];
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
        //animate little star friend to appear from behind moon
        [UIImageView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [starsImageView addSubview:littleStarFriendImageView];
            littleStarFriendImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
            
        } completion:^(BOOL finished) {
        }];
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, cloudsImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self makeItRain];
    }];
}

-(void)displayScene11n {
    // clouds 10, stars 28, moon 29, little star 30, lightning 31, 32, 33, 34
    
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas28];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas29];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width+30, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas10];
    
    UIImageView *littleStarFriendImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width/5, 25, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    littleStarFriendImageView.image = [WeatherStyleKit imageOfCanvas30];
    
    
    // add lightning imageViews
    UIImageView *lightningOneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height/2)];
    lightningOneImageView.image = [WeatherStyleKit imageOfCanvas31];
    lightningOneImageView.alpha = 0;
    [starsImageView addSubview: lightningOneImageView];
    
    UIImageView *lightningTwoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height/2)];
    lightningTwoImageView.image = [WeatherStyleKit imageOfCanvas32];
    lightningTwoImageView.alpha = 0;
    [cloudsImageView addSubview: lightningTwoImageView];
    
    UIImageView *lightningThreeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height/2)];
    lightningThreeImageView.image = [WeatherStyleKit imageOfCanvas33];
    lightningThreeImageView.alpha = 0;
    [cloudsImageView addSubview: lightningThreeImageView];
    
    UIImageView *lightningFourImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height/2)];
    lightningFourImageView.image = [WeatherStyleKit imageOfCanvas34];
    lightningFourImageView.alpha = 0;
    [cloudsImageView addSubview: lightningFourImageView];
    
    UIImageView *lightningFiveImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height/2)];
    lightningFiveImageView.image = [WeatherStyleKit imageOfCanvas35];
    lightningFiveImageView.alpha = 0;
    [starsImageView addSubview: lightningFiveImageView];
    
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:starsImageView];
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        
    } completion:^(BOOL finished) {
        // start rain
        [self makeItRainHard];
        
        //animate little star friend to appear from behind moon
        [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [starsImageView addSubview:littleStarFriendImageView];
            littleStarFriendImageView.frame = CGRectMake(-30, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
            
        } completion:^(BOOL finished) {
            // animate lightning
            [self flashLightningView:lightningOneImageView withDelayInterval:3];
            [self flashLightningView:lightningTwoImageView withDelayInterval:0];
            [self flashLightningView:lightningThreeImageView withDelayInterval:7];
            [self flashLightningView:lightningFourImageView withDelayInterval:4];
            [self flashLightningView:lightningFiveImageView withDelayInterval:5.25];
        }];
        
        [UIImageView animateWithDuration:0.1 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            littleStarFriendImageView.frame = CGRectMake(-littleStarFriendImageView.frame.size.width/2.6, -20, littleStarFriendImageView.frame.size.width*1.5 , littleStarFriendImageView.frame.size.height*1.5);
            
        } completion:^(BOOL finished) {
        }];
        
        [UIImageView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            littleStarFriendImageView.frame = CGRectMake(-30, 0, littleStarFriendImageView.frame.size.width/1.5 , littleStarFriendImageView.frame.size.height/1.5);
            
        } completion:^(BOOL finished) {
        }];
        
        [UIImageView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            littleStarFriendImageView.frame = CGRectMake(0, 0, littleStarFriendImageView.frame.size.width, littleStarFriendImageView.frame.size.height);
            
        } completion:^(BOOL finished) {
        }];
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(-30, 0, cloudsImageView.frame.size.width+30, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene13n {
    // clouds 36, stars 37, moon 38
    // image views to be animated
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    starsImageView.image = [WeatherStyleKit imageOfCanvas37];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    moonImageView.image = [WeatherStyleKit imageOfCanvas38];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas36];
    
    // animate stars in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:starsImageView];
        
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:moonImageView];
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self makeItSnowAtNight];
    }];
    
    //animate clouds in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        cloudsImageView.frame = CGRectMake(0, 0, cloudsImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)displayScene50n {
    // clouds 13, moon 38, stars 37 fog 39, 40, 42, 43
    UIImageView *starsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(self.iconImageView.frame.size.width, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    
    starsImageView.image = [WeatherStyleKit imageOfCanvas28];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-self.iconImageView.frame.size.width, 100, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height)];
    
    moonImageView.image = [WeatherStyleKit imageOfCanvas38];
    
    UIImageView *cloudsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(-(self.iconImageView.frame.size.width+30), 0, self.iconImageView.frame.size.width+30, self.iconImageView.frame.size.height)];
    
    cloudsImageView.image = [WeatherStyleKit imageOfCanvas13];
    
    
    // add FOG imageViews
    UIImageView *fogOneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-470, 0, 470, self.iconImageView.frame.size.height+20)];
    fogOneImageView.image = [WeatherStyleKit imageOfCanvas39];
    
    UIImageView *fogTwoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(470, 0, 470, self.iconImageView.frame.size.height+20)];
    fogTwoImageView.image = [WeatherStyleKit imageOfCanvas40];
    
    UIImageView *fogThreeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-470, 0, 470, self.iconImageView.frame.size.height+20)];
    fogThreeImageView.image = [WeatherStyleKit imageOfCanvas42];
    
    UIImageView *fogFourImageView = [[UIImageView alloc]initWithFrame:CGRectMake(470, 0, 470,self.iconImageView.frame.size.height+20)];
    fogFourImageView.image = [WeatherStyleKit imageOfCanvas43];
    
    // animate stars and fog in from right
    [UIImageView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:starsImageView];
        [self.view addSubview:fogOneImageView];
        [self.view addSubview:fogThreeImageView];
        
        starsImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        fogTwoImageView.frame = CGRectMake(-25, 0, fogOneImageView.frame.size.width, fogOneImageView.frame.size.height);
        fogFourImageView.frame = CGRectMake(-25, 0, fogThreeImageView.frame.size.width, fogThreeImageView.frame.size.height);
    } completion:^(BOOL finished) {
        
        [self floatFogImageView:fogTwoImageView withDuration:4 andWithDelay:3];
        [self floatFogImageView:fogFourImageView withDuration:5 andWithDelay:0];
    }];
    
    //animate moon in from lower left position
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:moonImageView];
        
        moonImageView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //animate clouds and fog in from left
    [UIImageView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.view addSubview:cloudsImageView];
        [self.view addSubview:fogTwoImageView];
        [self.view addSubview:fogFourImageView];
        
        cloudsImageView.frame = CGRectMake(0, 0, cloudsImageView.frame.size.width, cloudsImageView.frame.size.height);
        fogOneImageView.frame = CGRectMake(-25, 0, fogThreeImageView.frame.size.width, fogThreeImageView.frame.size.height);
        fogThreeImageView.frame = CGRectMake(-25, 0, fogFourImageView.frame.size.width, fogFourImageView.frame.size.height);
    } completion:^(BOOL finished) {
        
        [self floatFogImageView:fogOneImageView withDuration:6 andWithDelay:1];
        [self floatFogImageView:fogThreeImageView withDuration:5 andWithDelay:6];
    }];
}

-(void)displaySceneForNoIconCode {
    self.iconImageView.image = [WeatherStyleKit imageOfCanvas18];
}


# pragma mark - Animation and particle emitter methods

-(void)animateDayTimeLightninGuysImageView:(UIImageView *)lightningImageView withDelay:(float)delay {
    
    [UIImageView animateKeyframesWithDuration:2 delay:delay options:0 animations:^{
        
        [UIImageView addKeyframeWithRelativeStartTime:0 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
            lightningImageView.alpha = 0.5;
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.05 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
            lightningImageView.alpha = 1;
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x + 1, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x - 1, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x + 2, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x - 2, lightningImageView.frame.origin.y + 1, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x + 2, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x - 2, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x + 2, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.45 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x - 2, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x + 3, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.55 relativeDuration:0.05 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x - 3, lightningImageView.frame.origin.y, lightningImageView.frame.size.width, lightningImageView.frame.size.height/1.01);
        }];
        [UIImageView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.4 animations:^{
            lightningImageView.frame = CGRectMake(lightningImageView.frame.origin.x, self.iconImageView.frame.size.height, lightningImageView.frame.size.width, lightningImageView.frame.size.height*5);
        }];
        
    } completion:^(BOOL finished) {
        
        lightningImageView.alpha = 0;
        lightningImageView.frame = CGRectMake(0, 0,lightningImageView.frame.size.width, self.iconImageView.frame.size.height);
        [self animateDayTimeLightninGuysImageView:lightningImageView withDelay:delay];
    }];
}

-(void)sunRaysImageViewFlicker:(UIImageView *)sunRaysImageView withDelay:(float)delayTime {
    
    [UIImageView animateWithDuration:2 delay: delayTime options:0 animations:^{
        
        sunRaysImageView.alpha = 0.08;
        
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:2 delay: 0 options:0 animations:^{
            
            sunRaysImageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            // catch for first sun beam
            if (delayTime == 0) {
                
                [self sunRaysImageViewFlicker:sunRaysImageView withDelay:3];
            }
            else {
                
                [self sunRaysImageViewFlicker:sunRaysImageView withDelay:delayTime];
            }
        }];
    }];
}


-(void)makeItRain {
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    
    // puts rain behind clouds
    [self.iconImageView addSubview:self.sceneView];
    
    SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"RainSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:particleSystem withTransform:SCNMatrix4MakeScale(1, 1.5, 1)];
    particleSystem.birthRate = 200;
    
    [self bringLabelsAndTouchablesToFront];
}


-(void)makeItRainHard {
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    
    // puts rain behind clouds
    [self.iconImageView addSubview:self.sceneView];
    
    SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"RainSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:particleSystem withTransform:SCNMatrix4MakeScale(1, 1, 1)];
    particleSystem.birthRate = 150;
    
    [self bringLabelsAndTouchablesToFront];
}


-(void)makeItSnowInDaylight {
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.sceneView];
    
    
    // puts snow behind clouds
    [self.iconImageView addSubview:self.sceneView];
    
    SCNParticleSystem *snowParticleSystem = [SCNParticleSystem particleSystemNamed:@"SnowSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:snowParticleSystem withTransform:SCNMatrix4MakeScale(1, 1.4, 1)];
    
    [self bringLabelsAndTouchablesToFront];
}


-(void)makeItSnowAtNight {
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.sceneView];
    
    // puts snow behind clouds
    [self.iconImageView addSubview:self.sceneView];
    
    SCNParticleSystem *snowParticleSystem = [SCNParticleSystem particleSystemNamed:@"SnowSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:snowParticleSystem withTransform:SCNMatrix4MakeScale(1, 1.5, 1)];
    
    [self bringLabelsAndTouchablesToFront];
}

-(void)flashLightningView: (UIImageView *)lightningImageView withDelayInterval: (float)delayInterval {
    
    [UIImageView animateWithDuration:0.05 delay:delayInterval options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        lightningImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIImageView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            lightningImageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            // catch to stop first lightning bolt from striking too fast.
            if (delayInterval == 0) {
                [self flashLightningView:lightningImageView withDelayInterval:4];
            }
            else {
                [self flashLightningView:lightningImageView withDelayInterval:delayInterval];
            }
        }];
    }];
}


-(void)floatFogImageView:(UIImageView *)fogImageView withDuration:(float)duration andWithDelay:(float)delay {
    
    //up and right
    [UIImageView animateWithDuration:duration delay:delay options:0 animations:^{
        
        fogImageView.frame = CGRectMake(fogImageView.frame.origin.x + 4, fogImageView.frame.origin.y, fogImageView.frame.size.width, fogImageView.frame.size.height);
        fogImageView.transform = CGAffineTransformMakeScale(1.04, 1.02);
    } completion:^(BOOL finished) {
    }];
    //down and right
    [UIImageView animateWithDuration:duration delay:duration+delay options:0 animations:^{
        
        fogImageView.frame = CGRectMake(fogImageView.frame.origin.x +4, fogImageView.frame.origin.y, fogImageView.frame.size.width, fogImageView.frame.size.height);
        fogImageView.transform = CGAffineTransformMakeScale(1.04, 1);
    } completion:^(BOOL finished) {
    }];
    //down and left
    [UIImageView animateWithDuration:duration delay:2*duration+delay options:0 animations:^{
        
        fogImageView.frame = CGRectMake(fogImageView.frame.origin.x - 4, fogImageView.frame.origin.y, fogImageView.frame.size.width, fogImageView.frame.size.height);
        fogImageView.transform = CGAffineTransformMakeScale(1/1.04, 1/1.02);
    } completion:^(BOOL finished) {
    }];
    //up and left
    [UIImageView animateWithDuration:duration delay:3*duration+delay options:0 animations:^{
        
        fogImageView.frame = CGRectMake(fogImageView.frame.origin.x - 4, fogImageView.frame.origin.y, fogImageView.frame.size.width, fogImageView.frame.size.height);
        fogImageView.transform = CGAffineTransformMakeScale(1/1.04, 1);
    } completion:^(BOOL finished) {
        [self floatFogImageView:fogImageView withDuration:duration andWithDelay:delay];
    }];
}


-(void)setupParticleEmitterForWeatherScenes {
    
    // check weather icon to set up rain/snow particle emitters
    // day scenes
    if ([self.selectedCity.iconID isEqualToString:@"09d"]) {
        [self makeItRain];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10d"]) {
        [self makeItRain];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11d"]) {
        [self makeItRainHard];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13d"]) {
        [self makeItSnowInDaylight];
    }
    
    //night time scenes
    else if ([self.selectedCity.iconID isEqualToString:@"09n"]) {
        [self makeItRain];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10n"]) {
        [self makeItRain];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11n"]) {
        [self makeItRainHard];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13n"]) {
        [self makeItSnowAtNight];
    }
}



# pragma mark - Set color methods

-(void)setTextAndBackgroundColorsForIconCode {
    
    // check for weather icon code to display image
    if ([self.selectedCity.iconID isEqualToString:@"01d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas41];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"02d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas41];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"03d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas41];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"04d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas41];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"09d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas65];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas65];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas65];
        [self setDayTimeTextLabelColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas73];
        [self setDayTimeSnowSceneColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"50d"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas65];
        [self setDayTimeTextLabelColors];
    }
    
    //nighttime canvases
    else if ([self.selectedCity.iconID isEqualToString:@"01n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"02n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"03n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"04n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"09n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"10n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"11n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"13n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas11];
        [self setNightSnowSceneColors];
    }
    else if ([self.selectedCity.iconID isEqualToString:@"50n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas21];
        [self setNightTimeLabelTextColors];
    }
    // add screen for lack of icon code or no data?
    else {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas18];
        [self setNightTimeLabelTextColors];
    }
}


-(void)setNightTimeLabelTextColors {
    
    self.cityNameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.descriptionLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.tempLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.moreInfoLabel.textColor =  [[UIColor cyanColor] colorWithAlphaComponent:0.6];
    [self.moreInfoButton setTitleColor: [[UIColor cyanColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
}

-(void)setDayTimeTextLabelColors {
    self.cityNameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.descriptionLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.tempLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.moreInfoLabel.textColor =  [[UIColor cyanColor] colorWithAlphaComponent:0.8];
    [self.moreInfoButton setTitleColor: [[UIColor cyanColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
}

-(void)setNightSnowSceneColors {
    self.cityNameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.descriptionLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.tempLabel.textColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.moreInfoLabel.textColor =  [[UIColor cyanColor] colorWithAlphaComponent:0.8];
    [self.moreInfoButton setTitleColor: [[UIColor cyanColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
}

-(void)setDayTimeSnowSceneColors {
    self.cityNameLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.descriptionLabel.textColor =  [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.tempLabel.textColor =  [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.moreInfoLabel.textColor =  [[UIColor blueColor] colorWithAlphaComponent:0.9];
    self.moreInfoLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    [self.moreInfoButton setTitleColor: [[UIColor blueColor] colorWithAlphaComponent:0.9] forState:UIControlStateNormal];
}

@end
