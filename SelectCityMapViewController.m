//
//  MapViewController.m

#import "SelectCityMapViewController.h"
#import "WeatherAppDataStore.h"
#import "PossibleCity.h"
#import "SelectedCity.h"


@interface SelectCityMapViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *pinTapGestureRecognizer;

@end


@implementation SelectCityMapViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.topLabel.text = [NSString stringWithFormat:@"Select which %@", self.cityName];
    
    self.mapView.delegate = self;
    [self.view sendSubviewToBack: self.mapView];
    
    [self.mapView removeAnnotations: self.mapView.annotations];
    [self.mapView addAnnotations: self.possibleCitiesArrayOfMKAnnotations];
    
    self.pinTapGestureRecognizer.delegate = self;
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mapView showAnnotations: self.possibleCitiesArrayOfMKAnnotations animated: YES];
}


-(MKAnnotationView *)mapView: (MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *reuseID = @"SelectCityMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier: reuseID];
    
    if(!view) {
    
        view = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: reuseID];
        view.canShowCallout = YES;

    }
    
    view.annotation = annotation;
    return view;
}


#pragma mark - TouchActions

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view {

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame = CGRectMake(0, 0, 36, 36);
    addButton.layer.borderWidth = 1;
    addButton.layer.borderColor = self.view.tintColor.CGColor;
    addButton.layer.cornerRadius = 6;
    addButton.layer.backgroundColor = [self.view.tintColor colorWithAlphaComponent:0.1].CGColor;

    view.leftCalloutAccessoryView = addButton;
    
    [view addGestureRecognizer: self.pinTapGestureRecognizer];
}


-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    //removes gesture recognizer from deselected MKAnnotationView
    for (UITapGestureRecognizer *gestureRecognizer in view.gestureRecognizers) {
     
        [view removeGestureRecognizer: gestureRecognizer];
    }
}




- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender {

    NSLog(@"Tap Sender: %@", sender);
    
    // cast view.annotation to get citydictionary back
    // this gave me some trouble
    if(sender.state == UIGestureRecognizerStateEnded) {
        
        for (PossibleCity *possibleCity in self.mapView.selectedAnnotations) {
            
            NSDictionary *cityDict = possibleCity.cityDictionary;
    
            //save selected city to Core Data
    
            WeatherAppDataStore *sharedDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
            SelectedCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedCity"inManagedObjectContext:sharedDataStore.managedObjectContext];
            newCity.cityID = [cityDict[@"_id"] integerValue];
            newCity.cityName = cityDict[@"name"];
            newCity.countryName = cityDict[@"country"];
            newCity.lat = [cityDict[@"coord"][@"lat"] floatValue];
            newCity.lon = [cityDict[@"coord"][@"lon"] floatValue];
            newCity.updated = NO;
            newCity.dateSelected = [NSDate date].timeIntervalSinceReferenceDate;
        
            NSLog(@"SAVE IS ABOUT TO BE CALLED WITH CITY: %@", newCity);
    
            [sharedDataStore saveContext];
    
    
            [self performSegueWithIdentifier:@"unwindSegue" sender:self];
        }
    }
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    NSLog(@"Are we in here?!?!");
    // cast view.annotation to get citydictionary back
    
    PossibleCity *possibleCity = (PossibleCity *)view.annotation;
    
    NSDictionary *cityDict = possibleCity.cityDictionary;
    
    //save selected city to Core Data
    
    WeatherAppDataStore *sharedDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    SelectedCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedCity" inManagedObjectContext:sharedDataStore.managedObjectContext];
    newCity.cityID = [cityDict[@"_id"] integerValue];
    newCity.cityName = cityDict[@"name"];
    newCity.countryName = cityDict[@"country"];
    newCity.lat = [cityDict[@"coord"][@"lat"] floatValue];
    newCity.lon = [cityDict[@"coord"][@"lon"] floatValue];
    newCity.updated = NO;
    newCity.dateSelected = [NSDate date].timeIntervalSinceReferenceDate;
    
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
