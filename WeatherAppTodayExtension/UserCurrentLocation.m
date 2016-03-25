//
//  UserCurrentLocation.m


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
