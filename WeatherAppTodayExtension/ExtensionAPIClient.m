//
//  ExtensionAPIClient.m


#import "ExtensionAPIClient.h"

@implementation ExtensionAPIClient

# pragma mark - Today Extension API calls

+(void)getWeatherForCurrentLocation:(CLLocation *)userCurrentLocation withCompletionBlock:(void(^)(NSDictionary *responseDictionary))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", [NSString stringWithFormat:@"%.8f", userCurrentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", userCurrentLocation.coordinate.longitude]];
    
    NSLog(@"URLString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!data) {
            NSLog(@"Error in API Client data: error: %@ \n localizedDescription: %@", error, error.localizedDescription);
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

+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", iconIDString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!data) {
            NSLog(@"Error in API Client IconImage dataTask: %@", error);
        }
        
        NSData *dataResponse = [NSData dataWithData:data];
        
        if(!dataResponse) {
            NSLog(@"error in dataResponse. Error: %@ \nError.localizedDiscription: %@",error, error.localizedDescription);
        }
        
        UIImage *iconImage = [UIImage imageWithData:dataResponse];
        
        completionBlock(iconImage);
        
    }];
    
    [dataTask resume];
}


@end
