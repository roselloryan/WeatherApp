//
//  NSManagedObject+Insert.h
//  WeatherApp
//
//  Created by RYAN ROSELLO on 6/8/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Insert)

+ (instancetype)insertEntityIntoContext:(NSManagedObjectContext *)context;
+ (NSString *)entityName;

@end
