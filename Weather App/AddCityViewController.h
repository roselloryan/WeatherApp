//
//  AddCityViewController.h
//  Weather App
//
//  Created by RYAN ROSELLO on 1/5/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherAppTableViewController.h"


@interface AddCityViewController : UIViewController

@property (strong, nonatomic) NSArray *allCitiesArray;
@property (strong, nonatomic) NSMutableArray *possibleCitiesArrayOfMKAnnotations;
@end
