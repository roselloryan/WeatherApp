//
//  MapViewController.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/11/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SelectCityMapViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *possibleCitiesArrayOfMKAnnotations;
@property (strong, nonatomic) NSString *cityName;

@end
