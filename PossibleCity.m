//
//  PossibleCity.m


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
