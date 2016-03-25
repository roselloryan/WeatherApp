//
//  CurrentCityWeather.m


#import "CurrentCityWeather.h"

@implementation CurrentCityWeather


-(instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary {
 
    self = [super init];
    
    if (self) {
        
        _iconID = responseDictionary[@"weather"][0][@"icon"];
        _cityName = responseDictionary[@"name"];
        
        CGFloat tempInCelsius = [responseDictionary[@"main"][@"temp"] floatValue] -273;
        CGFloat tempInFahrenheit = (tempInCelsius * 1.8) + 32;
        NSString *tempString = [NSString stringWithFormat:@"%.0f°C / %.0f°F", roundf(tempInCelsius), roundf(tempInFahrenheit)];
        _tempInCelsiusAndFahrenheit = tempString;
        _lastUpdateAttempt = [NSDate date];
    }
    
    return self;
}

@end
