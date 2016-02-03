//
//  UserCurrentLocation.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/21/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface UserCurrentLocation : NSObject

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end
