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

@interface DetailWeatherVIewControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation DetailWeatherVIewControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set labels with weather data
    self.cityNameLabel.text = self.cityWithWeather.cityName;
    [self.view bringSubviewToFront:self.cityNameLabel];
    
    //temperature in C° and F°
    
    NSString *tempString = [NSString stringWithFormat:@"%@ / %@", self.cityWithWeather.tempInCelsius, self.cityWithWeather.tempInFahrenheit];
    NSLog(@"///In detailVC/// tempString: %@", tempString);
    
    self.tempLabel.text = tempString;
    self.descriptionLabel.text = self.cityWithWeather.weatherDescription;
    
    [self.view bringSubviewToFront:self.tempLabel];
    [self.view bringSubviewToFront:self.descriptionLabel];
    
    
    // check for weather icon code to display image
    if ([self.cityWithWeather.iconID isEqualToString:@"01d"]) {

        self.iconImageView.image = WeatherStyleKit.imageOfCanvas2;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"02d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas3;

    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"03d"]) {
      self.iconImageView.image = WeatherStyleKit.imageOfCanvas5;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"04d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas5;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"09d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas12;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"10d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas14;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"11d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas15;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"13d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas17;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"50d"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas16;
    }
    //nighttime canvases
    else if ([self.cityWithWeather.iconID isEqualToString:@"01n"]) {
        self.iconImageView.image = WeatherStyleKit.imageOfCanvas4;
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"02n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas7];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"03n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas6];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"04n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas1];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"09n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas8];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"10n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas9];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"11n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas10];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"13n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas11];
    }
    else if ([self.cityWithWeather.iconID isEqualToString:@"50n"]) {
        self.iconImageView.image = [WeatherStyleKit imageOfCanvas13];
    }
    // add screen for lack of icon code or no data?!?!

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
