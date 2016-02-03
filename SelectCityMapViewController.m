//
//  MapViewController.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/11/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "SelectCityMapViewController.h"
#import "WeatherAppDataStore.h"
#import "PossibleCity.h"
#import "SelectedCity.h"


@interface SelectCityMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end

@implementation SelectCityMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topLabel.text = [NSString stringWithFormat:@"Select which %@", self.cityName];
    
    self.mapView.delegate = self;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations: self.possibleCitiesArrayOfMKAnnotations];
    [self.mapView showAnnotations:self.possibleCitiesArrayOfMKAnnotations animated:YES];
    
    
}


// add right callout accesory and button to MKAnnotationViews
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *reuseID = @"SelectCityMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
    
    if(!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
        
        view.canShowCallout = YES;
        UIButton *checkButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 46, 46)];
        [checkButton setTitle:@"✅" forState:UIControlStateNormal];
        view.rightCalloutAccessoryView = checkButton;
        
    }
    view.annotation = annotation;
    
    return view;
}

#pragma mark - TouchActions

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    // cast view.annotation to get citydictionary back
    // this gave me some trouble
    
    PossibleCity *possibleCity = (PossibleCity *)view.annotation;
    
    NSDictionary *cityDict = possibleCity.cityDictionary;
    
    NSLog(@"cityDictionary from view is %@", cityDict);
    
    
    //save selected city to Core Data

    WeatherAppDataStore *sharedDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    SelectedCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedCity" inManagedObjectContext:sharedDataStore.managedObjectContext];
    newCity.cityID = [cityDict[@"_id"] integerValue];
    newCity.cityName = cityDict[@"name"];
    newCity.countryName = cityDict[@"country"];
    newCity.lat = [cityDict[@"coord"][@"lat"] floatValue];
    newCity.lon = [cityDict[@"coord"][@"lon"] floatValue];
    newCity.dateSelected = NSTimeIntervalSince1970;
    
    NSLog(@"SAVE IS ABOUT TO BE CALLED WITH CITY: %@", newCity);
    
    [sharedDataStore saveContext];
    
    [self performSegueWithIdentifier:@"unwindSegue" sender:self];
    
}


- (IBAction)cancelButtonTapped:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
