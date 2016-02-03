//
//  WeatherAppDataStore.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/6/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectedCity.h"

@interface WeatherAppDataStore : NSObject

@property (strong, nonatomic) NSArray *selectedCitiesArray;
@property (strong, nonatomic) NSMutableArray *citiesWithWeatherArray;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


+ (instancetype)sharedWeatherAppDataStore;

-(void)getWeatherWithCompletion:(void (^)(BOOL success))completionBlock;

- (void)saveContext;

-(void)fetchSelectedCities;

-(void)deleteSelectedCityWithID:(NSInteger)cityID;

@end
