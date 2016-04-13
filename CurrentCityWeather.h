//
//  CurrentCityWeather.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CurrentCityWeather : NSObject

@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *tempInCelsiusAndFahrenheit;
@property (strong, nonatomic) NSString *iconID;
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSDate *lastUpdateAttempt;


-(instancetype)initWithResponseDictionary:(NSDictionary *)responseDictionary;


@end
