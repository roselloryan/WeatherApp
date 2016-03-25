//
//  PossibleCity.h


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PossibleCity : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;
@property (nonatomic, readwrite, copy, nullable) NSDictionary *cityDictionary;


-(nonnull instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                         andTitle:(nonnull NSString *)cityNameAndCountry;

@end
