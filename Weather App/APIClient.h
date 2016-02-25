//
//  APIClient.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/5/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APIClient : NSObject

+(void)getWeatherForCityID:(NSInteger)cityID WithCompletionBlock:(void(^)(NSDictionary *responseDictionary, NSError *error))completionBlock;

+(void)getIconImageForIconID:(NSString *)iconIDString withCompletionBlock:(void(^)(UIImage *iconImage, NSError *error))completionBlock;
@end
