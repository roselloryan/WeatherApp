
//  WeatherAppDataStore.m


#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import <CoreData/CoreData.h>
#import "SelectedCity.h"

@implementation WeatherAppDataStore

+ (instancetype)sharedWeatherAppDataStore {
    static WeatherAppDataStore *_sharedWeatherAppDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherAppDataStore = [[WeatherAppDataStore alloc] init];
    });
    
    return _sharedWeatherAppDataStore;
}


-(void)getWeatherWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    
    for (NSInteger i =0 ; i<self.selectedCitiesArray.count; i++) {

        SelectedCity *selectedCity = self.selectedCitiesArray[i];
 
        NSFetchRequest *updateFetch = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
        updateFetch.predicate = [NSPredicate predicateWithFormat:@"cityID= %ld",selectedCity.cityID];
        NSArray *fetchArray = [self.managedObjectContext executeFetchRequest: updateFetch error: nil];
        
        for(SelectedCity *managedSelectedCity in fetchArray) {

            NSTimeInterval timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:managedSelectedCity.updateLastAttempt];
            NSLog(@"_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_>_timeSinceLastUpdate: %f POSITIVE OR NEGATIVE", timeSinceLastUpdate);
            NSTimeInterval tenMinutesInSeconds = 600;
            
                if (managedSelectedCity.updated == NO || timeSinceLastUpdate > tenMinutesInSeconds) {
                
                    NSInteger cityID = managedSelectedCity.cityID;
            
                    //API client calls and returns weather dictionary for each city then builds cityWithWeather object.
                    [APIClient getWeatherForCityID:cityID WithCompletionBlock:^(NSDictionary *responseDictionary, NSError *error) {
                
                        if (!responseDictionary) {
                            // pass error through.
                            NSLog(@"sharedDataStore error: error passed through from API: %@", error);
                    
                            managedSelectedCity.updateLastAttempt = [NSDate date];
                            NSLog(@"didn't get a responseDictionary from API call and set an updateAttemptTime for managedSelecetedCity: %@", managedSelectedCity.cityName);

                            [self saveContext];
                            completionBlock(nil, error);
                        }
                
                        else {
                            //update selected city's weather data from responseDictionary
                            managedSelectedCity.tempInCelsius = [NSString stringWithFormat:@"%.0f°C",roundf([responseDictionary[@"main"][@"temp"] floatValue] -273.15)];
                            managedSelectedCity.tempInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp"] floatValue]-273))+32) ];
                            managedSelectedCity.weatherDescription = responseDictionary[@"weather"][0][@"description"];
                    
                            managedSelectedCity.tempHighInCelsius = [NSString stringWithFormat:@"%.0f°C", roundf([responseDictionary[@"main"][@"temp_max"] floatValue] -273.15)];
                            managedSelectedCity.tempHighInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_max"] floatValue]-273))+32)];
                            managedSelectedCity.tempLowInCelsius = [NSString stringWithFormat:@"%.0f°C",   round([responseDictionary[@"main"][@"temp_min"] floatValue] -273.15)];
                            managedSelectedCity.tempLowInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_min"] floatValue]-273))+32)];
                    
                            managedSelectedCity.humidity =[NSString stringWithFormat:@"%@%%", responseDictionary[@"main"][@"humidity"]];
                            managedSelectedCity.atmosphericPressure = [NSString stringWithFormat:@"%@hPa", responseDictionary[@"main"][@"pressure"]];
                            managedSelectedCity.windSpeedMPH = [NSString stringWithFormat:@"%.1fmph", ([responseDictionary[@"wind"][@"speed"]floatValue] * 2.236936)];
                            managedSelectedCity.windSpeedKPH = [NSString stringWithFormat:@"%.1fkm/h", ([responseDictionary[@"wind"][@"speed"]floatValue] * 3.6)];
                            managedSelectedCity.iconID = [NSString stringWithFormat:@"%@", responseDictionary[@"weather"][0][@"icon"]];
                    
                    
                    
                            NSLog(@"updatedCityWeatherWindSpeedMPH: %@", managedSelectedCity.windSpeedMPH);
                            NSLog(@"newCity's selected city.update %d", managedSelectedCity.updated);
                    
                            managedSelectedCity.updated = YES;
                            managedSelectedCity.updateLastAttempt = [NSDate date];
                            NSLog(@"newCity's selected city.update %d", managedSelectedCity.updated);
                    
                            [self saveContext];

                    
                        }
                    }];
                }
                else {
                    NSLog(@"This City doesn't need updating.");
            }
        }
    }
    NSLog(@"+++++++++++++++++ABOUT TO CALL THE COMPLETION BLOCK+++++++++++++++++++");
    completionBlock(YES, nil);
}

-(void)getWeatherForSelectedCity:(SelectedCity *)selectedCity withCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    
        
    NSFetchRequest *updateFetch = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
    updateFetch.predicate = [NSPredicate predicateWithFormat:@"cityID= %ld",selectedCity.cityID];
    NSArray *fetchArray = [self.managedObjectContext executeFetchRequest: updateFetch error: nil];
        
    for(SelectedCity *managedSelectedCity in fetchArray) {
            
        NSTimeInterval timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:managedSelectedCity.updateLastAttempt];
        NSLog(@">_>_>_>_>_>_>_>_>_>_>_>_>_>_timeSinceLastUpdate: %f POSITIVE OR NEGATIVE", timeSinceLastUpdate);
        NSTimeInterval tenMinutesInSeconds = 600;
            
        if (managedSelectedCity.updated == NO || timeSinceLastUpdate > tenMinutesInSeconds) {
                
            NSInteger cityID = managedSelectedCity.cityID;
                
            //API client calls and returns weather dictionary for each city then builds cityWithWeather object.
            [APIClient getWeatherForCityID:cityID WithCompletionBlock:^(NSDictionary *responseDictionary, NSError *error) {
                    
                if (!responseDictionary) {
                    // pass error through.
                    NSLog(@"sharedDataStore error: error passed through from API: %@", error);
                        
                    managedSelectedCity.updateLastAttempt = [NSDate date];
                    NSLog(@"didn't get a responseDictionary from API call and set an updateAttemptTime for managedSelecetedCity: %@", managedSelectedCity.cityName);
                        
                    [self saveContext];
                    NSLog(@"++++++++++ABOUT TO CALL THE COMPLETION BLOCK (nil, error)+++++++++++++++++++");
                    completionBlock(nil, error);
                    }
                    
                else {
                    //update selected city's weather data from responseDictionary
                    managedSelectedCity.tempInCelsius = [NSString stringWithFormat:@"%.0f°C",roundf([responseDictionary[@"main"][@"temp"] floatValue] -273.15)];
                    managedSelectedCity.tempInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp"] floatValue]-273))+32) ];
                    managedSelectedCity.weatherDescription = responseDictionary[@"weather"][0][@"description"];
                        
                    managedSelectedCity.tempHighInCelsius = [NSString stringWithFormat:@"%.0f°C", roundf([responseDictionary[@"main"][@"temp_max"] floatValue] -273.15)];
                    managedSelectedCity.tempHighInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_max"] floatValue]-273))+32)];
                    managedSelectedCity.tempLowInCelsius = [NSString stringWithFormat:@"%.0f°C",   round([responseDictionary[@"main"][@"temp_min"] floatValue] -273.15)];
                    managedSelectedCity.tempLowInFahrenheit = [NSString stringWithFormat:@"%.0f°F", roundf((1.8*([responseDictionary[@"main"][@"temp_min"] floatValue]-273))+32)];
                    
                    managedSelectedCity.humidity =[NSString stringWithFormat:@"%@%%", responseDictionary[@"main"][@"humidity"]];
                    managedSelectedCity.atmosphericPressure = [NSString stringWithFormat:@"%@hPa", responseDictionary[@"main"][@"pressure"]];
                    managedSelectedCity.windSpeedMPH = [NSString stringWithFormat:@"%.1fmph", ([responseDictionary[@"wind"][@"speed"]floatValue] * 2.236936)];
                    managedSelectedCity.windSpeedKPH = [NSString stringWithFormat:@"%.1fkm/h", ([responseDictionary[@"wind"][@"speed"]floatValue] * 3.6)];
                    managedSelectedCity.iconID = [NSString stringWithFormat:@"%@", responseDictionary[@"weather"][0][@"icon"]];
                        
                    managedSelectedCity.updated = YES;
                    managedSelectedCity.updateLastAttempt = [NSDate date];
                        
                    [self saveContext];
                        
                    NSLog(@"++++++++++ABOUT TO CALL THE COMPLETION BLOCK (YES, nil)+++++++++++++++++++");
                    completionBlock(YES, nil);
                    }
            }];
        }
        else {
                NSLog(@"This City doesn't need updating.");
                NSLog(@"+++++++++++++++++ABOUT TO CALL THE COMPLETION BLOCK (nil, nil)+++++++++++++++++++");
                completionBlock(YES, nil);
        }
    }
}

//for (NSInteger i =0 ; i<self.selectedCitiesArray.count; i++) {
//    
//    SelectedCity *selectedCity = self.selectedCitiesArray[i];
//    





//CURRENTLY NOT BEING USED. SECOND API CALL CAUSING TIMING ISSUES//
//-(void)addIconToCitiesWithWeatherWithCompletion:(void(^)(BOOL success))completionBlock {
//    
//    for(CityWithWeather *cityWithWeather in self.citiesWithWeatherArray) {
//        
//        //api call to get icon
//        [APIClient getIconImageForIconID: cityWithWeather.iconID withCompletionBlock:^(UIImage *iconImage, NSError *error) {
//             
//            if (!iconImage){
//                //handle that big mama nasty error
//                cityWithWeather.iconImage = nil;
//                
//            }
//            
//            else {
//            cityWithWeather.iconImage = iconImage;
//            NSLog(@"Got an Image!");
//            }
//        }];
//    }
//    completionBlock(YES);
//}



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
