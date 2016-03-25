//
//  APIClient.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APIClient : NSObject

+(void)getWeatherForCityID:(NSInteger)cityID withCompletionBlock:(void(^)(NSDictionary *responseDictionary, NSError *error))completionBlock;

//+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage, NSError *error))completionBlock;
@end
