//
//  WeatherAppTableViewController.m
//  Weather App
//

#import "WeatherAppTableViewController.h"
#import "DetailWeatherVIewControllerViewController.h"
#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import "AddCityViewController.h"
#import "SelectCityMapViewController.h"
#import "WeatherStyleKit.h"
#import <CoreGraphics/CoreGraphics.h>




@interface WeatherAppTableViewController ()

@property (strong, nonatomic) WeatherAppDataStore *sharedWeatherAppDataStore;


@end



@implementation WeatherAppTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad: called!!");
    
    self.navigationItem.title = @"Select City for Weather";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    self.tableView.backgroundColor = [UIColor clearColor];

    
    UIImageView *testImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    testImageView.image = [UIImage imageNamed:@"sun"];
    [self.navigationController.view addSubview:testImageView];
    [self.navigationController.view sendSubviewToBack:testImageView];
    
    // set up complete list of available cities. Yes. It's big.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city.list" ofType:@"json"];
    NSData *dataFromCityList = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error = nil;
    
    NSArray *arrayOfDictionariesForCities = [NSJSONSerialization JSONObjectWithData:dataFromCityList options:0 error:&error];
    
    if(!arrayOfDictionariesForCities) {
        // there was an error!
        NSLog(@"ERROR: %@", error);
    }
    self.allCitiesArray = arrayOfDictionariesForCities;
    NSLog(@"TableViewController allCitiestArray.count: %lu", self.allCitiesArray.count);
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    NSLog(@"viewWillAppear Before updadateWeatherData Called");
//    NSLog(@"WHAT IS THE selectedcities array count: %ld", self.sharedWeatherAppDataStore.selectedCitiesArray.count);
//    [self updateWeatherData];
//    NSLog(@"viewWillAppear AFTER updadateWeatherData Called");
//    NSLog(@"WHAT IS THE selectedcities array count: %ld", self.sharedWeatherAppDataStore.selectedCitiesArray.count);
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateWeatherData];
}

-(void)updateWeatherData {
    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    [self.sharedWeatherAppDataStore fetchSelectedCities];
    
    for (NSInteger i =0 ; i < self.sharedWeatherAppDataStore.selectedCitiesArray.count; i++) {
    
        SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[i];
    
    [self.sharedWeatherAppDataStore getWeatherForSelectedCity:selectedCity withCompletion:^(BOOL success, NSError *error) {
        
        NSLog(@"WE DONE!!!");
        if (success == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                NSLog(@"HELLO SUCCESS!!");
            }];
        }

        else if(success == NO && error) {
            //build alertControlleror
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", error.domain] message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // should I call this in viewDidAppear to avoid presenting controller during other VC presentation????
                
                [self.tableView reloadData];
                NSLog(@":::::::self.tableView reloadData CALLED:::::::");
                
                [self presentViewController:alertController animated:YES completion:^{
                    // anything to do here? maybe try api again? say something witty?
                }];
            }];
        }
    }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSLog(@"number Of Sections: %ld", self.sharedWeatherAppDataStore.selectedCitiesArray.count);
    return self.sharedWeatherAppDataStore.selectedCitiesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    UITableViewCell *cityCell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
   //check for visualEffectView to not keep adding views
    BOOL itDoesHaveVisualEffectView = NO;
    
    for (UIView *view in cityCell.subviews) {
        
        if ([view isKindOfClass:[UIVisualEffectView class]]) {
            itDoesHaveVisualEffectView = YES;
        }
    }
    //if no visualEffectView add one
    if (!itDoesHaveVisualEffectView) {
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = cityCell.bounds;
        
        [cityCell addSubview:visualEffectView];
        [cityCell sendSubviewToBack:visualEffectView];
    }
    
    

    SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];
    
    // check if data is current from fetch and api call
    
        cityCell.backgroundColor = [UIColor clearColor];
        [cityCell.layer setCornerRadius:15.0f];
        [cityCell.layer setMasksToBounds:YES];
        [cityCell.layer setBorderWidth:1.0f];
        [cityCell.layer setBorderColor: [UIColor grayColor].CGColor];
        
        NSString *cityWithCountryAbrreviation = [NSString stringWithFormat:@"%@, %@", selectedCity.cityName, selectedCity.countryName];
        NSString *tempString = [NSString stringWithFormat:@"%@/%@", selectedCity.tempInCelsius, selectedCity.tempInFahrenheit];
        cityCell.detailTextLabel.text = tempString;
        cityCell.textLabel.text = cityWithCountryAbrreviation;
    
    
    return cityCell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *cityNameTest = @"...";
    
    return cityNameTest;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *clearView = [[UIView alloc]init];
    clearView.backgroundColor = [UIColor clearColor];
    
    return clearView;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"DELETE SOME CITIES!!!");
        
        SelectedCity *cityToDelete = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];
        NSLog(@"Trying to delete:%@", cityToDelete.cityName);
        
        NSInteger cityID = cityToDelete.cityID;
        
        [self.sharedWeatherAppDataStore deleteSelectedCityWithID:cityID];
        
    }
    [self.tableView reloadData];
    NSLog(@":::::::self.tableView reloadData CALLED:::::::");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"addCitySegue"]) {
        
        AddCityViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.allCitiesArray = self.allCitiesArray;
    }
    
    // pass city dictionary forwrd to detailWeatherViewController
    else if([segue.identifier isEqualToString:@"detailWeatherViewControllerSegue"]) {
        
        DetailWeatherVIewControllerViewController *destinationVC = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        SelectedCity *city = self.sharedWeatherAppDataStore.selectedCitiesArray[selectedIndexPath.section];
        
        destinationVC.selectedCity = city;
        
    }
    
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)unwindSegue {
    
    UIViewController *sourceViewController = unwindSegue.sourceViewController;
    
    if([sourceViewController isKindOfClass:[SelectCityMapViewController class]]) {
        NSLog(@"Segue coming from Map!");
    }
    
}

//
//    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
//    [self.sharedWeatherAppDataStore fetchSelectedCities];
//
//    if(self.sharedWeatherAppDataStore.selectedCitiesArray.count != self.sharedWeatherAppDataStore.citiesWithWeatherArray.count) {
//
//        [self.sharedWeatherAppDataStore getWeatherWithCompletion:^(BOOL success, NSError *error) {
//
//            NSLog(@"WE DONE!!!");
//            if (success == YES) {
//                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//                    [self.tableView reloadData];
//                    NSLog(@"HELLO SUCCESS!!");
//                }];
//            }
//
//            else if(success == NO) {
//                //build alertControlerror
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Broken Things :(" message:@"The internet has been disrupted by the horrors of humanity. We're sorry to have to tell you like this." preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
//                [alertController addAction:okAction];
//
//                // should I call this in viewDidAppear to avoid presenting controller during animation of BACK from     Navigation Controller????
//
//                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//
//                    [self.tableView reloadData];
//                    [self presentViewController:alertController animated:YES completion:^{
//                        // anything to do here? maybe try api again? say something witty?
//                    }];
//                }];
//            }
//        }];
//    }


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    // Configure the cell...
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
//
//    // check if data is back from fetch and api call
//    if(self.sharedWeatherAppDataStore.citiesWithWeatherArray.count == 0){
//        SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.row];
//
//        cell.textLabel.text = selectedCity.cityName;
//        cell.detailTextLabel.text = @"searching for weather...";
//        return cell;
//
//    }
//    //city name and country
//
//    else {
//        CityWithWeather *city= self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row];
//
//        NSString *cityWithCountryAbrreviation = [NSString stringWithFormat:@"%@, %@", city.cityName, city.countryAbreviation];
//        NSString *tempString = [NSString stringWithFormat:@"%@/%@", city.tempInCelsius, city.tempInFahrenheit];
//
//        cell.detailTextLabel.text = tempString;
//        cell.textLabel.text = cityWithCountryAbrreviation;
//
//        return cell;
//    }
//}

@end
