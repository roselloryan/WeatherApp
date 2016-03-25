//
//  SearchViewController.h
//  Weather App


#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController

@property (strong, nonatomic) NSArray *allCitiesArray;

@property (strong, nonatomic) NSMutableArray *possibleCitiesArrayOfMKAnnotations;

@end
