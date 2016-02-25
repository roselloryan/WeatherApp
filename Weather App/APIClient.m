//
//  APIClient.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/5/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "APIClient.h"
#import "WeatherAppTableViewController.h"
#import "WeatherAppDataStore.h"
#import "UserCurrentLocation.h"




@implementation APIClient


+(void)getWeatherForCityID:(NSInteger)cityID WithCompletionBlock:(void(^)(NSDictionary *responseDictionary, NSError *error))completionBlock {
    
    NSLog(@"******************About to make an API call ***************************");
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%lu&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", cityID];
    
    NSLog(@"URLString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!data) {
            NSLog(@"NSURLSessionDataTask dataTaskWithURL error: %@", error);
            completionBlock(nil, error);
            return ;
        }
        
        //         handle HTTP errors here
        
//        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//            
//            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//            
//            if (statusCode != 200) {
//                NSError *error = [[NSError alloc]initWithDomain:@"HTTPResponse" code:statusCode userInfo:nil];
//                
//                NSLog(@"HTTP error: %@", error);
//                NSLog(@"HTTP status code: %lu", statusCode);
//                //                completionBlock (nil, error);
//            }
//        }
        
        
        // do something with response
        
        NSError *dictionaryError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dictionaryError];
        
        if (responseDictionary && responseDictionary != NULL) {
            
            NSLog(@"=============WE ARE GOOD==============");
            NSLog(@"response dictionary: %@", responseDictionary);
            
            NSLog(@"=============WE ARE GOOD==============\n");

            
            completionBlock(responseDictionary, nil);
            

            
        } else {
            
            NSLog(@"NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,");
            completionBlock(nil, dictionaryError);
        }
        
        
        
    }];
    
    [dataTask resume];
}


+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage, NSError *error))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", iconIDString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!data) {
            
            NSLog(@"Error in API Client IconImage data: %@", error);
            completionBlock(nil, error);
        }
        
        NSData *dataResponse = [NSData dataWithData:data];
        
        UIImage *iconImage = [UIImage imageWithData:dataResponse];
        
        completionBlock(iconImage, nil);
        
    }];
    
    [dataTask resume];
}

/*
 You can get ahold of its path with `[[NSBundle mainBundle] pathForResource:@"blah" ofType:@"json"]`
 And then get yourself an nsdata of that with `dataWithContentsOfFile:`
 
 ​[4:58]
 And the finally feed that into nsjsonserialization
 
 ​[4:58]
 It's a fun dance. Fast though
 
 */



@end
