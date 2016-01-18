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


@implementation APIClient


+(void)getWeatherForCityID:(NSInteger)cityID WithCompletionBlock:(void(^)(NSDictionary *responseDictionary))completionBlock {
        
    
        NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%lu&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", cityID];
        
        NSLog(@"URLString: %@", urlString);
    
        NSURL *url = [NSURL URLWithString:urlString];
    
        NSURLSession *session = [NSURLSession sharedSession];
    
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(!dataTask) {
                NSLog(@"Error in API Client dataTask: %@", error);
            }
           
            // do something with response
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if(!responseDictionary) {
                NSLog(@"Error in API Client response dictionary: %@", error);
            }
            
            NSLog(@"response dictionary: %@", responseDictionary);
            
            completionBlock(responseDictionary);
            
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

/* +(void)getAlbumCoverUrl:(NSString *)trackID withCompletionBlock:(void (^)(NSString *albumCoverLink))completionBlock {
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/tracks/%@", trackID];
    
    NSURL *albumCoverURL = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *albumCoverDataTask = [session dataTaskWithURL:albumCoverURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSLog(@"Respose Dictionary: %@", responseDictionary);
        
        NSDictionary *albumDictionary = responseDictionary[@"album"];
        NSLog(@"albumDictionary: %@", albumDictionary);
        
        NSArray *imagesArray =albumDictionary[@"images"];
        NSLog(@"imagesArray: %@", imagesArray);
        
        NSDictionary *imageDictionary = imagesArray[1];
        NSLog(@"imageDictionary: %@", imageDictionary);
        
        NSString *albumCoverLink = imageDictionary[@"url"];
        NSLog(@"albumCoverLink: %@", albumCoverLink);
        
        
        completionBlock(albumCoverLink);
    }];
    
    [albumCoverDataTask resume];
}
*/

@end
