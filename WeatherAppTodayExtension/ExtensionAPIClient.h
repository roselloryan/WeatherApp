//
//  ExtensionAPIClient.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/21/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ExtensionAPIClient : NSObject

+(void)getWeatherForCurrentLocation:(CLLocation *)userCurrentLocation withCompletionBlock:(void(^)(NSDictionary *responseDictionary))completionBlock;

@end
