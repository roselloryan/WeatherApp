//
//  ExtensionAPIClient.h


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface ExtensionAPIClient : NSObject

+(void)getWeatherForCurrentLocation:(CLLocation *)userCurrentLocation withCompletionBlock:(void(^)(NSDictionary *responseDictionary))completionBlock;

+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage))completionBlock;

@end
