//
//  APIClient.m


#import "APIClient.h"
#import "WeatherAppDataStore.h"
#import "UserCurrentLocation.h"


@implementation APIClient


+(void)getWeatherForCityID:(NSInteger)cityID withCompletionBlock:(void(^)(NSDictionary *responseDictionary, NSError *error))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%lu&appid=02fc2da6e2b5f9da39cb7b95a3210d2c", cityID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // log http error here if it helps
        
        if (!data) {

            completionBlock(nil, error);
            return ;
        }
        
        // do something with response
        NSError *dictionaryError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dictionaryError];
        
        if (responseDictionary && responseDictionary != nil) {
            
            completionBlock(responseDictionary, nil);
        }
        
        else {
            
            completionBlock(nil, dictionaryError);
        }
    }];
    
    [dataTask resume];
}


@end
