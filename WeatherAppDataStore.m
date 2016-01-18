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

-(void)getWeatherWithCompletion:(void (^)(BOOL success))completionBlock {

    
    if(self.selectedCitiesArray.count != 0) {
        
        [self.citiesWithWeatherArray removeAllObjects];
        
        for (SelectedCity *selectedCity in self.selectedCitiesArray) {
            
            NSLog(@"\n\n ==== \n\n");
            NSLog(@"%@", selectedCity);
            NSLog(@"\n\n ==== \n\n");

        
        
            NSInteger cityID = selectedCity.cityID;
       
            //API client calls and returns weather dictionary for each city.
            [APIClient getWeatherForCityID:cityID WithCompletionBlock:^(NSDictionary *responseDictionary) {
                [self.citiesWithWeatherArray addObject: responseDictionary];
         
                //check if all cities have response dictionary with weather
                if (self.selectedCitiesArray.count == self.citiesWithWeatherArray.count && self.selectedCitiesArray.count > 0) {
                    completionBlock(YES);
                }
            }];
         
        }
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
    self.selectedCitiesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
     
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}







@end
