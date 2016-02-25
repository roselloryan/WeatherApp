//
//  DetailWeatherVIewControllerViewController.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/13/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "DetailWeatherVIewControllerViewController.h"
#import "APIClient.h"
#import "WeatherStyleKit.h"
#import <SceneKit/SceneKit.h>


@interface DetailWeatherVIewControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@end

@implementation DetailWeatherVIewControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sceneView.scene = [SCNScene scene];
    self.sceneView.scene.background.contents = nil;
    self.sceneView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.sceneView];
    
    //set labels with weather data
    self.cityNameLabel.font = [UIFont fontWithName:@"Optima" size:40];
    self.cityNameLabel.text = self.selectedCity.cityName;
    [self.view bringSubviewToFront:self.cityNameLabel];
    
    //temperature in C° and F°
    
    NSString *tempString = [NSString stringWithFormat:@"%@ / %@", self.selectedCity.tempInCelsius, self.selectedCity.tempInFahrenheit];
    NSLog(@"///In detailVC/// tempString: %@", tempString);
    
    self.tempLabel.font = [UIFont fontWithName:@"Optima" size:55];
    self.tempLabel.text = tempString;
    self.descriptionLabel.font = [UIFont fontWithName:@"Optima" size:30];
    self.descriptionLabel.text = self.selectedCity.weatherDescription;
    
    [self.view bringSubviewToFront:self.tempLabel];
    [self.view bringSubviewToFront:self.descriptionLabel];
    

    
//    self.sceneView.scene = [SCNScene scene];
//    self.sceneView.scene.background.contents = nil;
//    self.sceneView.backgroundColor = [UIColor clearColor];
//    [self.view bringSubviewToFront:self.sceneView];
    
    
//    // check for weather icon code to display image
//    if ([self.selectedCity.iconID isEqualToString:@"01d"]) {
//
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas2;
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"02d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas3;
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"03d"]) {
//      self.iconImageView.image = WeatherStyleKit.imageOfCanvas5;
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"04d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas5;
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"09d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas12;
//        [self makeItRain];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"10d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas14;
//        [self makeItRain];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"11d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas15;
//        [self makeItRainHard];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"13d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas17;
//        [self makeItSnowInDaylight];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"50d"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas16;
//    }
//    //nighttime canvases
//    else if ([self.selectedCity.iconID isEqualToString:@"01n"]) {
//        self.iconImageView.image = WeatherStyleKit.imageOfCanvas4;
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"02n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas7];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"03n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas6];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"04n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas1];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"09n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas8];
//        [self makeItRain];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"10n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas9];
//        [self makeItRain];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"11n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas10];
//        [self makeItRainHard];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"13n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas11];
//        [self makeItSnowAtNight];
//    }
//    else if ([self.selectedCity.iconID isEqualToString:@"50n"]) {
//        self.iconImageView.image = [WeatherStyleKit imageOfCanvas13];
//    }
    // add screen for lack of icon code or no data?!?!

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.iconImageView.image = [WeatherStyleKit imageOfCanvas11];
    [self makeItSnowAtNight];
    
    NSLog(@"iconID: %@", self.selectedCity.iconID);
}

-(void)makeItRain {
    self.sceneView.scene = [SCNScene scene];
    
    SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"RainSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:particleSystem withTransform:SCNMatrix4MakeScale(1, 1.5, 1)];
    particleSystem.birthRate = 1000;
}


-(void)makeItRainHard {
    self.sceneView.scene = [SCNScene scene];
    
    SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"RainSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:particleSystem withTransform:SCNMatrix4MakeScale(1, 1.5, 1)];
    particleSystem.birthRate = 2000;
    particleSystem.speedFactor = 1;
}


-(void)makeItSnowInDaylight {

    SCNParticleSystem *snowParticleSystem = [SCNParticleSystem particleSystemNamed:@"SnowSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:snowParticleSystem withTransform:SCNMatrix4MakeScale(1, 1.4, 1)];
    //y-axis 1.4 for day snow :)
    //y-axis 1.8 for night snow
}


-(void)makeItSnowAtNight {
 
    
    SCNParticleSystem *snowParticleSystem = [SCNParticleSystem particleSystemNamed:@"SnowSceneKitParticleSystem" inDirectory:nil];
    [self.sceneView.scene addParticleSystem:snowParticleSystem withTransform:SCNMatrix4MakeScale(1, 1.8, 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
