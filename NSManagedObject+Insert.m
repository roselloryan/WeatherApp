//
//  NSManagedObject+Insert.m
//  WeatherApp
//
//  Created by RYAN ROSELLO on 6/8/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "NSManagedObject+Insert.h"

@implementation NSManagedObject (Insert)

+ (instancetype)insertEntityIntoContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

@end
