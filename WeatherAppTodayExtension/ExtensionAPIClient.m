//
//  ExtensionAPIClient.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/21/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "ExtensionAPIClient.h"

@implementation ExtensionAPIClient

# pragma mark - Today Extension API calls

+(void)getWeatherForCurrentLocation:(CLLocation *)userCurrentLocation withCompletionBlock:(void(^)(NSDictionary *responseDictionary))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", [NSString stringWithFormat:@"%.8f", userCurrentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", userCurrentLocation.coordinate.longitude]];
    
    NSLog(@"URLString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!dataTask) {
            NSLog(@"Error in API Client dataTask: error: %@ \n localizedDescription: %@", error, error.localizedDescription);
        }
        
        // do something with response
        NSError *responseDictionaryError = nil;
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(!responseDictionary) {
            NSLog(@"Error in API Client response dictionary: error: %@ \n localized discription: %@", responseDictionaryError, responseDictionaryError.localizedDescription);
        
        }
        
        NSLog(@"response dictionary: %@", responseDictionary);
        
        completionBlock(responseDictionary);
        
    }];
    
    [dataTask resume];
}


@end
