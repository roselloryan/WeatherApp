
//  WeatherAppDataStore.h


#import <Foundation/Foundation.h>
#import "SelectedCity.h"

@interface WeatherAppDataStore : NSObject


@property (strong, nonatomic) NSArray *selectedCitiesArray;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



+ (instancetype)sharedWeatherAppDataStore;

-(void)getWeatherWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

-(void)getWeatherForSelectedCity:(SelectedCity *)selectedCity withCompletion:(void (^)(BOOL success, NSError *error))completionBlock;
    
- (void)saveContext;

-(void)fetchSelectedCities;

-(void)deleteSelectedCityWithID:(NSInteger)cityID;

@end
