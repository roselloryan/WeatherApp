//
//  SelectedCity+CoreDataProperties.m
//  Weather App
//
//  Created by RYAN ROSELLO on 2/17/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SelectedCity+CoreDataProperties.h"

@implementation SelectedCity (CoreDataProperties)

@dynamic cityID;
@dynamic cityName;
@dynamic countryName;
@dynamic dateSelected;
@dynamic lat;
@dynamic lon;
@dynamic updated;
@dynamic tempInCelsius;
@dynamic tempInFahrenheit;
@dynamic weatherDescription;
@dynamic tempHighInCelsius;
@dynamic tempHighInFahrenheit;
@dynamic tempLowInCelsius;
@dynamic tempLowInFahrenheit;
@dynamic humidity;
@dynamic atmosphericPressure;
@dynamic windSpeedMPH;
@dynamic windSpeedKPH;
@dynamic iconID;
@dynamic sunrise;
@dynamic sunset;
@dynamic updateLastAttempt;

@end
