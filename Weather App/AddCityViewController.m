//
//  AddCityViewController.m


#import "AddCityViewController.h"
#import "WeatherAppDataStore.h"
#import "PossibleCity.h"
#import "SelectCityMapViewController.h"
#import "WeatherStyleKit.h"

@interface AddCityViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;

@property (weak, nonatomic) IBOutlet UIButton *addCityButton;


@end

@implementation AddCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up background image
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    self.possibleCitiesArrayOfMKAnnotations = [[NSMutableArray alloc]init];
    
    // set up text field behaviors
    [self.cityTextField becomeFirstResponder];
    self.cityTextField.delegate = self;
    
    
    // set appearance of navigationBar
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [self.navigationController.navigationBar setBackgroundImage: [UIImage new]  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    //setup addCity button appearance
    self.addCityButton.layer.cornerRadius = 5;
    self.addCityButton.layer.borderWidth = 1;
    self.addCityButton.layer.borderColor = self.view.tintColor.CGColor;
    
}


#pragma mark - touchActions

- (IBAction)addCityButtonTapped:(UIButton *)sender {
    
    if ([self.cityTextField.text isEqualToString:@""]) {
        
        UIAlertController *noTextEnteredAlert = [UIAlertController alertControllerWithTitle:@"No Text Entered" message:@"Please enter a city name to search" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [noTextEnteredAlert addAction:okAction];
        [self presentViewController:noTextEnteredAlert animated:YES completion:nil];
    }
    else {
        [self checkForCityMatchAndSave];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SelectCityMapViewController *destinationVC = segue.destinationViewController;
    destinationVC.cityName = self.cityTextField.text;
    destinationVC.possibleCitiesArrayOfMKAnnotations =self.possibleCitiesArrayOfMKAnnotations;
    
    
}


#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if ([self.cityTextField.text isEqualToString:@""]) {
        
        UIAlertController *noTextEnteredAlert = [UIAlertController alertControllerWithTitle:@"No Text Entered" message:@"Please enter a city name to search" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [noTextEnteredAlert addAction:okAction];
        [self presentViewController:noTextEnteredAlert animated:YES completion:nil];
    }

    else {
        [self checkForCityMatchAndSave];
    }
    return YES;
}



-(void)checkForCityMatchAndSave {
    
    NSMutableArray *possibleCitiesArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *cityDictionary in self.allCitiesArray) {
        
        if([[cityDictionary objectForKey:@"name"] isEqualToString: self.cityTextField.text]) {
            
            [possibleCitiesArray addObject:cityDictionary];
        }
    }
    
    
    if(possibleCitiesArray.count > 1) {
        // put pins on a map and ask user to pick which city
        NSLog(@"possible cities array: %@", possibleCitiesArray);
        
        //build array of possible city objects conforming to MKAnnotation protocol
        
        for(NSDictionary *cityDictionary in possibleCitiesArray) {
            
            NSString *cityNameAndCountry = [NSString stringWithFormat:@"%@, %@", cityDictionary[@"name"],cityDictionary[@"country"]];
            
            CLLocationCoordinate2D newCityCoordinate = CLLocationCoordinate2DMake([cityDictionary[@"coord"][@"lat"] floatValue], [cityDictionary[@"coord"][@"lon"] floatValue]);
            
            PossibleCity *newCity = [[PossibleCity alloc]initWithCoordinate:newCityCoordinate andTitle:cityNameAndCountry];
            newCity.cityDictionary = cityDictionary;
            
            [self.possibleCitiesArrayOfMKAnnotations addObject:newCity];
        }
        
        //segue to SelectCityMapViewController'
        [self performSegueWithIdentifier:@"selectCityFromMapSegue" sender:nil];
        
        NSLog(@"possibleCitiesArrayOfMKAnnotations: %@", self.possibleCitiesArrayOfMKAnnotations);
        
    }
    
    // just one matching city
    else if(possibleCitiesArray.count == 1) {
        
        WeatherAppDataStore *sharedDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
        SelectedCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedCity" inManagedObjectContext:sharedDataStore.managedObjectContext];
        
        newCity.cityName = possibleCitiesArray[0][@"name"];
        newCity.countryName = possibleCitiesArray[0][@"country"];
        newCity.cityID = [possibleCitiesArray[0][@"_id"] integerValue];
        newCity.lat = [possibleCitiesArray[0][@"coord"][@"lat"] floatValue];
        newCity.lon = [possibleCitiesArray[0][@"coord"][@"lon"] floatValue];
        newCity.updated = nil;
        newCity.dateSelected = [NSDate date].timeIntervalSinceReferenceDate;
        
        
        NSLog(@"NOT IN THE MAP: IS THIS GETTING SAVED!!!!! %@", newCity);
        
        [sharedDataStore saveContext];

        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    else {
        
        UIAlertController *noMatchAlert = [UIAlertController alertControllerWithTitle:@"No Match" message:@"No Matching City Found \n Please Check Spelling and Try Again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [noMatchAlert addAction:okAction];
        [self presentViewController:noMatchAlert animated:YES completion:nil];
    }
    
    NSLog(@"self.allCitiesArray.count: %lu", self.allCitiesArray.count);
    
}


@end
