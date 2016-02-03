//
//  SelectedCity+CoreDataProperties.h
//  Weather App
//
//  Created by RYAN ROSELLO on 2/1/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SelectedCity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectedCity (CoreDataProperties)

@property (nonatomic) int64_t cityID;
@property (nullable, nonatomic, retain) NSString *cityName;
@property (nullable, nonatomic, retain) NSString *countryName;
@property (nonatomic) float lat;
@property (nonatomic) float lon;
@property (nonatomic) NSTimeInterval dateSelected;

@end

NS_ASSUME_NONNULL_END
