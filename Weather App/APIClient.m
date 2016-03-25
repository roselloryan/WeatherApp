//
//  APIClient.m


#import "APIClient.h"
#import "WeatherAppTableViewController.h"
#import "WeatherAppDataStore.h"
#import "UserCurrentLocation.h"




@implementation APIClient


+(void)getWeatherForCityID:(NSInteger)cityID withCompletionBlock:(void(^)(NSDictionary *responseDictionary, NSError *error))completionBlock {
    
    NSLog(@"******************About to make an API call ***************************");
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%lu&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", cityID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"%@", urlString);
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        NSLog(@"In API ClIENT looking for http response code: %@", response);
        
        if (!data) {
            NSLog(@"NSURLSessionDataTask dataTaskWithURL error: %@", error);

            completionBlock(nil, error);
            return ;
        }
        
        // do something with response
        NSError *dictionaryError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dictionaryError];
        
        if (responseDictionary && responseDictionary != nil) {
            
            NSLog(@"response dictionary: %@", responseDictionary);
            completionBlock(responseDictionary, nil);
        }
        
        else {
            
            completionBlock(nil, dictionaryError);
        }
    }];
    
    [dataTask resume];
}

//
//+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage, NSError *error))completionBlock {
//    
//    NSString *urlString = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", iconIDString];
//    
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if(!data) {
//            
//            NSLog(@"Error in API Client IconImage data: %@", error);
//            completionBlock(nil, error);
//        }
//        
//        NSData *dataResponse = [NSData dataWithData:data];
//        UIImage *iconImage = [UIImage imageWithData:dataResponse];
//        
//        completionBlock(iconImage, nil);
//    }];
//    
//    [dataTask resume];
//}

/*
 You can get ahold of its path with `[[NSBundle mainBundle] pathForResource:@"blah" ofType:@"json"]`
 And then get yourself an nsdata of that with `dataWithContentsOfFile:`
 
 ​[4:58]
 And the finally feed that into nsjsonserialization
 
 ​[4:58]
 It's a fun dance. Fast though
 
 */



@end
