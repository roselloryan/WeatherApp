//
//  DetailWeatherVIewControllerViewController.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/13/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "DetailWeatherVIewControllerViewController.h"

@interface DetailWeatherVIewControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DetailWeatherVIewControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.cityDictionary);
    
    //set labels with weather data
    self.cityNameLabel.text = self.cityDictionary[@"name"];
    //temperature in C° and F°
    
    CGFloat tempInCelsius = [self.cityDictionary[@"main"][@"temp"] floatValue] -273.15;
    
    CGFloat tempInFahrenheit = (tempInCelsius * 9/5) + 32;
    
    NSString *tempString = [NSString stringWithFormat:@"%.0f°C / %.0f°F", roundf(tempInCelsius), roundf(tempInFahrenheit)];
    NSLog(@"In detailVC: %@", tempString);
    
    self.tempLabel.text = tempString;
    self.descriptionLabel.text = self.cityDictionary[@"weather"][0][@"description"];
    
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
