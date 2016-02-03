//
//  UserCurrentLocation.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/21/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "UserCurrentLocation.h"

@implementation UserCurrentLocation

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D )coordinate {
    self = [super init];
    
    if (self) {
        _coordinate = coordinate;
        
    }
    
    return  self;
}



@end
