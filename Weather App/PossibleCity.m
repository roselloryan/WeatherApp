//
//  PossibleCity.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/12/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "PossibleCity.h"

@implementation PossibleCity 

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)cityNameAndCountry {
    
    self = [super init];
    
    if(self) {
        _coordinate = coordinate;
        _title = cityNameAndCountry;
    }
    
    return self;
}


@end
