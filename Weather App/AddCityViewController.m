//
//  AddCityViewController.m
//  Weather App
//
//  Created by RYAN ROSELLO on 1/5/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import "AddCityViewController.h"
#import "WeatherAppDataStore.h"
#import "PossibleCity.h"
#import "SelectCityMapViewController.h"

@interface AddCityViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;


@end

@implementation AddCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.possibleCitiesArrayOfMKAnnotations = [[NSMutableArray alloc]init];
    
    // set up text field behaviors
    [self.cityTextField becomeFirstResponder];
    self.cityTextField.delegate = self;

    
}


#pragma mark - touchActions

- (IBAction)addCityButtonTapped:(UIButton *)sender {
    
    [self checkForCityMatchAndSave];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SelectCityMapViewController *destinationVC = segue.destinationViewController;
    destinationVC.cityName = self.cityTextField.text;
    destinationVC.possibleCitiesArrayOfMKAnnotations =self.possibleCitiesArrayOfMKAnnotations;
    
    
}


#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self checkForCityMatchAndSave];
    
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
        newCity.dateSelected = NSTimeIntervalSince1970;
        
        NSLog(@"NOT IN THE MAP: IS THIS GETTING SAVED!!!!! %@", newCity);
        
        [sharedDataStore saveContext];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    else {
        
        UIAlertController *noMatchAlert = [UIAlertController alertControllerWithTitle:@"No Match" message:@"No Matching City Found \n Check Spelling and Try Again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [noMatchAlert addAction:okAction];
        [self presentViewController:noMatchAlert animated:YES completion:nil];
    }
    
    NSLog(@"self.allCitiesArray.count: %lu", self.allCitiesArray.count);
    
}

@end
