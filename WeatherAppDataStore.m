//
//  WeatherAppDataStore.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/6/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import <CoreData/CoreData.h>
#import "CityWithWeather.h"

@implementation WeatherAppDataStore

+ (instancetype)sharedWeatherAppDataStore {
    static WeatherAppDataStore *_sharedWeatherAppDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherAppDataStore = [[WeatherAppDataStore alloc] init];
    });
    
    return _sharedWeatherAppDataStore;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _citiesWithWeatherArray = [[NSMutableArray alloc] init];
        
        [self fetchSelectedCities];
    }
    return self;
}

-(void)getWeatherWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {

    
    if(self.selectedCitiesArray.count != 0) {
        
        [self.citiesWithWeatherArray removeAllObjects];
        
        for (SelectedCity *selectedCity in self.selectedCitiesArray) {
            
            NSLog(@"selectedCity in datastore: %@", selectedCity);
            
            
            NSInteger cityID = selectedCity.cityID;
       
            //API client calls and returns weather dictionary for each city then builds cityWithWeather object.
            
            [APIClient getWeatherForCityID:cityID WithCompletionBlock:^(NSDictionary *responseDictionary, NSError *error) {
                
                if (!responseDictionary) {
                    // pass error through.
                    completionBlock(NO, error);
                    
                }
                
                else {
                //build cityWithWeatherObjects
                
                CityWithWeather *newCity = [[CityWithWeather alloc]init];
                newCity.cityID = responseDictionary[@"id"];
                newCity.cityName = responseDictionary[@"name"];
                newCity.countryAbreviation = responseDictionary[@"sys"][@"country"];
                newCity.dateSelected = selectedCity.dateSelected;
                NSLog(@"newCity.dateSelected: %f", newCity.dateSelected);
                NSLog(@"selectedCity.dateSelected: %f", selectedCity.dateSelected);
                
                newCity.tempInCelsius = [NSString stringWithFormat:@"%.0f°C",roundf([responseDictionary[@"main"][@"temp"] floatValue] -273.15)];
                newCity.tempInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp"] floatValue]-273))+32) ];
                newCity.weatherDescription = responseDictionary[@"weather"][0][@"description"];
               
                newCity.tempHighInCelsius = [NSString stringWithFormat:@"%.0f°C", roundf([responseDictionary[@"main"][@"temp_max"] floatValue] -273.15)];
                newCity.tempHighInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_max"] floatValue]-273))+32)];
                newCity.tempLowInCelsius = [NSString stringWithFormat:@"%.0f°C", roundf([responseDictionary[@"main"][@"temp_min"] floatValue] -273.15)];
                newCity.tempLowInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_min"] floatValue]-273))+32)];
                
                newCity.humidity =[NSString stringWithFormat:@"%@%%", responseDictionary[@"main"][@"humidity"]];
                newCity.atmosphericPressure = [NSString stringWithFormat:@"%@hPa", responseDictionary[@"main"][@"pressure"]];
                newCity.windSpeedMPH = [NSString stringWithFormat:@"%.1fmph", ([responseDictionary[@"wind"][@"speed"]floatValue] * 2.236936)];
                newCity.windSpeedKPH = [NSString stringWithFormat:@"%.1fkm/h", ([responseDictionary[@"wind"][@"speed"]floatValue] * 3.6)];
                newCity.iconID = responseDictionary[@"weather"][0][@"icon"];
                
                NSLog(@"newCity: %@", newCity);
                
                
                [self.citiesWithWeatherArray addObject: newCity];
         
                //check if all cities have response dictionary with weather
                if (self.selectedCitiesArray.count == self.citiesWithWeatherArray.count && self.selectedCitiesArray.count > 0) {
                        completionBlock(YES, nil);
                }
                }
            }];
        }
    }
}


-(void)deleteSelectedCityWithID:(NSInteger)cityID {
    // PUT THIS IN THE DATASTORE!!!
    NSFetchRequest *deleteFetch = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
    
    deleteFetch.predicate = [NSPredicate predicateWithFormat:@"cityID= %ld",cityID];
    NSLog(@"CityID: %ld", cityID);
    
    NSArray *fetchArray = [self.managedObjectContext executeFetchRequest: deleteFetch error: nil];
    
    for(NSManagedObject *managedObject in fetchArray) {
        
        [self.managedObjectContext deleteObject:managedObject];
        [self saveContext];
        [self fetchSelectedCities];

        NSLog(@"---IN THE DELETE FOR LOOP IN DATASTORE NOW!!!---");
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


# pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"selectedCitiesModel.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"selectedCitiesModel" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


//!!! ADD Error Handling!!! ///

-(void)fetchSelectedCities {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
//    self.selectedCitiesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateSelected" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.selectedCitiesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (self.selectedCitiesArray == nil) {
        
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
    }
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
     
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}







@end
