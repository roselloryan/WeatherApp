//
//  SelectedCity+CoreDataProperties.h
//  Weather App
//
//  Created by RYAN ROSELLO on 3/15/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SelectedCity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectedCity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *atmosphericPressure;
@property (nonatomic) int64_t cityID;
@property (nullable, nonatomic, retain) NSString *cityName;
@property (nullable, nonatomic, retain) NSString *countryName;
@property (nonatomic) NSTimeInterval dateSelected;
@property (nullable, nonatomic, retain) NSString *humidity;
@property (nullable, nonatomic, retain) NSString *iconID;
@property (nonatomic) float lat;
@property (nonatomic) float lon;
@property (nonatomic) NSTimeInterval sunrise;
@property (nonatomic) NSTimeInterval sunset;
@property (nullable, nonatomic, retain) NSString *tempHighInCelsius;
@property (nullable, nonatomic, retain) NSString *tempHighInFahrenheit;
@property (nullable, nonatomic, retain) NSString *tempInCelsius;
@property (nullable, nonatomic, retain) NSString *tempInFahrenheit;
@property (nullable, nonatomic, retain) NSString *tempLowInCelsius;
@property (nullable, nonatomic, retain) NSString *tempLowInFahrenheit;
@property (nonatomic) BOOL updated;
@property (nonatomic) NSTimeInterval updateLastAttempt;
@property (nullable, nonatomic, retain) NSString *weatherDescription;
@property (nullable, nonatomic, retain) NSString *windSpeedKPH;
@property (nullable, nonatomic, retain) NSString *windSpeedMPH;

@end

NS_ASSUME_NONNULL_END
