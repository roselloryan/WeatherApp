//
//  WeatherAppDataStore.m


#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import <CoreData/CoreData.h>
#import "SelectedCity.h"
#import "WeatherStyleKit.h"


@implementation WeatherAppDataStore


+ (instancetype)sharedWeatherAppDataStore {
    static WeatherAppDataStore *_sharedWeatherAppDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherAppDataStore = [[WeatherAppDataStore alloc] init];
    });
    
    return _sharedWeatherAppDataStore;
}



-(void)getWeatherForSelectedCity:(SelectedCity *)selectedCity withCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    
    // fetch request to core data for saved city
    NSFetchRequest *updateFetch = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
    updateFetch.predicate = [NSPredicate predicateWithFormat:@"cityID= %ld",selectedCity.cityID];
    NSArray *fetchArray = [self.managedObjectContext executeFetchRequest: updateFetch error: nil];

    SelectedCity *managedSelectedCity = fetchArray[0];
    
    // check last update time
    NSTimeInterval timeSinceLastUpdate = ([NSDate date].timeIntervalSinceReferenceDate - managedSelectedCity.updateLastAttempt);
    NSTimeInterval tenMinutesInSeconds = 600;
    
            
        if (managedSelectedCity.updated == NO || timeSinceLastUpdate > tenMinutesInSeconds) {
            
            NSInteger cityID = managedSelectedCity.cityID;
            
            //API client calls and returns weather dictionary for each city then builds cityWithWeather object.
            [APIClient getWeatherForCityID:cityID withCompletionBlock:^(NSDictionary *responseDictionary, NSError *error) {
                    
                if (!responseDictionary) {
                    // pass error through.
                    NSLog(@"sharedDataStore error: error passed through from API: %@", error);

                    NSDate *rightNow = [NSDate date];
                    
                    managedSelectedCity.updateLastAttempt = rightNow.timeIntervalSinceReferenceDate  ;
                    
                    [self saveContext];

                    NSLog(@"%@", error);
                    
                    completionBlock(nil, error);
                    }
                    
                else {

                    //update selected city's weather data from responseDictionary
                    
                    [self addResponseDictionaryOfWeatherData:responseDictionary toManagedSelectedCity:managedSelectedCity];
                    
                    [self checkSelectedCityForNegativeZeroTemps:managedSelectedCity];

                    [self performSelectorInBackground:@selector(drawWeatherImageForIconID:) withObject:managedSelectedCity.iconID];
                        
                    managedSelectedCity.updated = YES;
                    managedSelectedCity.updateLastAttempt = [NSDate date].timeIntervalSinceReferenceDate;
                        
                    [self saveContext];
                    
                    completionBlock(YES, nil);
                    }
            }];
        }
        else {
                //This City doesn't need updating.
                completionBlock(YES, nil);
        }
}


-(void)checkSelectedCityForNegativeZeroTemps:(SelectedCity * )managedSelectedCity {

    if ([managedSelectedCity.tempInCelsius isEqualToString:@"-0°C"]) {
        managedSelectedCity.tempInCelsius = @"0°C";
    }
    if ([managedSelectedCity.tempInFahrenheit isEqualToString:@"-0°F"]) {
        managedSelectedCity.tempInFahrenheit = @"0°F";
    }
    if ([managedSelectedCity.tempHighInCelsius isEqualToString:@"-0°C"]) {
        managedSelectedCity.tempHighInCelsius = @"0°C";
    }
    if ([managedSelectedCity.tempHighInFahrenheit isEqualToString:@"-0°F"]){
        managedSelectedCity.tempHighInFahrenheit = @"0°F";
    }
    if ([managedSelectedCity.tempLowInCelsius isEqualToString:@"-0°C"]){
        managedSelectedCity.tempLowInCelsius = @"0°C";
    }
    if ([managedSelectedCity.tempLowInFahrenheit isEqualToString:@"-0°F"]){
        managedSelectedCity.tempLowInFahrenheit = @"0°F";
    }
}


-(NSInteger)celsiusFromDegreesKelvin:(float)degreesKelvin {
    
    NSInteger degreesCelsius = lround(degreesKelvin - 273.15);
    return degreesCelsius;
}


-(NSInteger)fahrenheitFromDegreesCelsius:(NSInteger)degreesCelsius {
    
    NSInteger degreesFahreheit = lround(degreesCelsius * 1.8 + 32);
    return degreesFahreheit;
}


-(void)addResponseDictionaryOfWeatherData:(NSDictionary *)responseDictionary toManagedSelectedCity:(SelectedCity *)managedSelectedCity {
    
    //update selected city's weather data from responseDictionary
    managedSelectedCity.tempInCelsius = [NSString stringWithFormat:@"%ld°C",[self celsiusFromDegreesKelvin:[responseDictionary[@"main"][@"temp"] floatValue]]];
    
    managedSelectedCity.tempInFahrenheit = [NSString stringWithFormat:@"%ld°F", [self fahrenheitFromDegreesCelsius:[managedSelectedCity.tempInCelsius integerValue]]];
    
    managedSelectedCity.weatherDescription = responseDictionary[@"weather"][0][@"description"];
    
    managedSelectedCity.tempHighInCelsius = [NSString stringWithFormat:@"%ld°C", [self celsiusFromDegreesKelvin:[responseDictionary[@"main"][@"temp_max"] floatValue]]];
    
    managedSelectedCity.tempHighInFahrenheit = [NSString stringWithFormat:@"%ld°F", [self fahrenheitFromDegreesCelsius:[managedSelectedCity.tempHighInCelsius integerValue]]];
    
    managedSelectedCity.tempLowInCelsius = [NSString stringWithFormat:@"%ld°C", [self celsiusFromDegreesKelvin:[responseDictionary[@"main"][@"temp_min"] floatValue]]];
    
    managedSelectedCity.tempLowInFahrenheit = [NSString stringWithFormat:@"%ld°F", [self fahrenheitFromDegreesCelsius:[managedSelectedCity.tempLowInCelsius integerValue]]];
    
    managedSelectedCity.humidity =[NSString stringWithFormat:@"%@%%", responseDictionary[@"main"][@"humidity"]];
    
    managedSelectedCity.atmosphericPressure = [NSString stringWithFormat:@"%ldhPa", lround([responseDictionary[@"main"][@"pressure"]floatValue])];
    managedSelectedCity.windSpeedMPH = [NSString stringWithFormat:@"%.1fmph", ([responseDictionary[@"wind"][@"speed"]floatValue] * 2.236936)];
    managedSelectedCity.windSpeedKPH = [NSString stringWithFormat:@"%.1fkmh", ([responseDictionary[@"wind"][@"speed"]floatValue] * 3.6)];
    managedSelectedCity.iconID = [NSString stringWithFormat:@"%@", responseDictionary[@"weather"][0][@"icon"]];
}


# pragma mark - method to draw the appropriate illustrations


-(void)drawWeatherImageForIconID:(NSString *)iconID {
    // check for weather icon code to display image
    if ([iconID isEqualToString:@"01d"]) {
        [WeatherStyleKit imageOfCanvas2];
        [WeatherStyleKit imageOfCanvas46];
        [WeatherStyleKit imageOfCanvas47];
        [WeatherStyleKit imageOfCanvas48];
        [WeatherStyleKit imageOfCanvas49];
    }
    else if ([iconID isEqualToString:@"02d"]) {
        [WeatherStyleKit imageOfCanvas3];
        [WeatherStyleKit imageOfCanvas44];
        [WeatherStyleKit imageOfCanvas45];
        [WeatherStyleKit imageOfCanvas51];
        [WeatherStyleKit imageOfCanvas52];
        [WeatherStyleKit imageOfCanvas53];
    }
    else if ([iconID isEqualToString:@"03d"]) {
        [WeatherStyleKit imageOfCanvas3];
        [WeatherStyleKit imageOfCanvas55];
        [WeatherStyleKit imageOfCanvas54];
    }
    else if ([iconID isEqualToString:@"04d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas57];
        [WeatherStyleKit imageOfCanvas58];
    }
    else if ([iconID isEqualToString:@"09d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas59];
        [WeatherStyleKit imageOfCanvas60];
    }
    else if ([iconID isEqualToString:@"10d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas59];
        [WeatherStyleKit imageOfCanvas60];
    }
    else if ([iconID isEqualToString:@"11d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas61];
        [WeatherStyleKit imageOfCanvas62];
        [WeatherStyleKit imageOfCanvas63];
        [WeatherStyleKit imageOfCanvas64];
    }
    else if ([iconID isEqualToString:@"13d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas74];
        [WeatherStyleKit imageOfCanvas75];
    }
    else if ([iconID isEqualToString:@"50d"]) {
        [WeatherStyleKit imageOfCanvas56];
        [WeatherStyleKit imageOfCanvas67];
        [WeatherStyleKit imageOfCanvas68];
        [WeatherStyleKit imageOfCanvas69];
        [WeatherStyleKit imageOfCanvas70];
        [WeatherStyleKit imageOfCanvas71];
        [WeatherStyleKit imageOfCanvas72];
    }
    
    //nighttime canvases
    else if ([iconID isEqualToString:@"01n"]) {
        [WeatherStyleKit imageOfCanvas4];
        [WeatherStyleKit imageOfCanvas22];
    }
    else if ([iconID isEqualToString:@"02n"]) {
        [WeatherStyleKit imageOfCanvas4];
        [WeatherStyleKit imageOfCanvas7];
        [WeatherStyleKit imageOfCanvas22];
    }
    else if ([iconID isEqualToString:@"03n"]) {
        [WeatherStyleKit imageOfCanvas6];
        [WeatherStyleKit imageOfCanvas22];
        [WeatherStyleKit imageOfCanvas23];
    }
    else if ([iconID isEqualToString:@"04n"]) {
        [WeatherStyleKit imageOfCanvas1];
        [WeatherStyleKit imageOfCanvas22];
        [WeatherStyleKit imageOfCanvas24];
    }
    else if ([iconID isEqualToString:@"09n"]) {
        [WeatherStyleKit imageOfCanvas8];
        [WeatherStyleKit imageOfCanvas25];
        [WeatherStyleKit imageOfCanvas26];
        [WeatherStyleKit imageOfCanvas27];
    }
    else if ([iconID isEqualToString:@"10n"]) {
        [WeatherStyleKit imageOfCanvas9];
        [WeatherStyleKit imageOfCanvas26];
        [WeatherStyleKit imageOfCanvas27];
        [WeatherStyleKit imageOfCanvas28];
    }
    else if ([iconID isEqualToString:@"11n"]) {
        [WeatherStyleKit imageOfCanvas10];
        [WeatherStyleKit imageOfCanvas28];
        [WeatherStyleKit imageOfCanvas29];
        [WeatherStyleKit imageOfCanvas30];
        [WeatherStyleKit imageOfCanvas31];
        [WeatherStyleKit imageOfCanvas32];
        [WeatherStyleKit imageOfCanvas33];
        [WeatherStyleKit imageOfCanvas34];
        [WeatherStyleKit imageOfCanvas35];
    }
    else if ([iconID isEqualToString:@"13n"]) {
        [WeatherStyleKit imageOfCanvas36];
        [WeatherStyleKit imageOfCanvas37];
        [WeatherStyleKit imageOfCanvas38];
    }
    else if ([iconID isEqualToString:@"50n"]) {
        
        [WeatherStyleKit imageOfCanvas13];
        [WeatherStyleKit imageOfCanvas37];
        [WeatherStyleKit imageOfCanvas38];
        [WeatherStyleKit imageOfCanvas39];
        [WeatherStyleKit imageOfCanvas40];
        [WeatherStyleKit imageOfCanvas42];
        [WeatherStyleKit imageOfCanvas43];
    }
    // screen for null icon code
    else {
        [WeatherStyleKit imageOfCanvas18];
    }
}


# pragma mark - Core Data Stack


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (NSManagedObjectContext *)managedObjectContext {
    
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


-(void)fetchSelectedCities {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];

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


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            // If this happens, we're pretty screwed. We don't have any model validations, so this means something is totally bonkers.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


-(void)deleteSelectedCityWithID:(NSInteger)cityID {
    
    NSFetchRequest *deleteFetch = [NSFetchRequest fetchRequestWithEntityName:@"SelectedCity"];
    
    deleteFetch.predicate = [NSPredicate predicateWithFormat:@"cityID= %ld",cityID];
    NSLog(@"City to delete: CityID: %ld", cityID);
    
    NSArray *fetchArray = [self.managedObjectContext executeFetchRequest: deleteFetch error: nil];
    
    for(NSManagedObject *managedObject in fetchArray) {
        
        [self.managedObjectContext deleteObject:managedObject];
        [self saveContext];
        [self fetchSelectedCities];
    }
}


-(BOOL)checkForDuplicateCityID:(NSInteger)cityID {
    
    for (SelectedCity *selectedCity in self.selectedCitiesArray) {
        
        if (selectedCity.cityID == cityID) {
            return YES;
            break;
        }
    }
    return NO;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
     
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
