//
//  cityWithWeather.h
//  Weather App
//
//  Created by RYAN ROSELLO on 2/10/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CityWithWeather : NSObject

@property (assign, nonatomic) NSString *cityID;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *countryAbreviation;
@property (assign, nonatomic) NSTimeInterval dateSelected;

@property (strong, nonatomic) NSString *tempInCelsius;
@property (strong, nonatomic) NSString *tempInFahrenheit;
@property (strong, nonatomic) NSString *weatherDescription;

@property (strong, nonatomic) NSString *tempHighInCelsius;
@property (strong, nonatomic) NSString *tempHighInFahrenheit;
@property (strong, nonatomic) NSString *tempLowInCelsius;
@property (strong, nonatomic) NSString *tempLowInFahrenheit;

@property (strong, nonatomic) NSString *humidity;
@property (strong, nonatomic) NSString *atmosphericPressure;
@property (strong, nonatomic) NSString *windSpeedMPH;
@property (strong, nonatomic) NSString *windSpeedKPH;

@property (assign, nonatomic) NSTimeInterval currentTime;
@property (assign, nonatomic) NSTimeInterval sunrise;
@property (assign, nonatomic) NSTimeInterval sunset;

@property (strong, nonatomic) NSString *iconID;
@property (strong, nonatomic) UIImage *iconImage;

@end
