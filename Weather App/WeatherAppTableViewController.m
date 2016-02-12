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
#import "CityWithWeather.h"


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
    
    
    //playing with gradients
//    
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.view.bounds;
//    gradient.colors = @[(id)[WeatherStyleKit sunBallGradientColor].CGColor,
//                        (id)[WeatherStyleKit sunBallGradientColor2].CGColor];
//    [self.view.layer addSublayer:gradient];
//    [self.view bringSubviewToFront:self.tableView];
    

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
    
    NSLog(@"viewWillAppear: GETTING CALLED!!!");    

    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    [self.sharedWeatherAppDataStore fetchSelectedCities];
    

    NSLog(@"WHAT IS THE selectedcities array count: %ld", self.sharedWeatherAppDataStore.selectedCitiesArray.count);

    if (self.sharedWeatherAppDataStore.selectedCitiesArray.count != self.sharedWeatherAppDataStore.citiesWithWeatherArray.count) {
        
        
        NSLog(@"DataStore.selectedCitiesArray In TableViewController: %@",self.sharedWeatherAppDataStore.selectedCitiesArray);
        
//        [self.sharedWeatherAppDataStore fetchSelectedCities];

        [self.sharedWeatherAppDataStore getWeatherWithCompletion:^(BOOL success, NSError *error) {
            
            NSLog(@"WE DONE!!!");
            if (success == YES) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.tableView reloadData];
                    NSLog(@"HELLO SUCCESS!!");
                }];
            }
            else if(success == NO) {
               //build alertControlerror
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Broken Things :(" message:@"The internet has been disrupted by the horrors of humanity. We're sorry to have to tell you like this." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:^{
                    // anything to do here? maybe try api again? say something witty?
                }];
            }
        }];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRows: %ld", self.sharedWeatherAppDataStore.selectedCitiesArray.count);
    return self.sharedWeatherAppDataStore.selectedCitiesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    
    // Configure the cell...
    // check if data is back from fetch and api call
    if(self.sharedWeatherAppDataStore.citiesWithWeatherArray.count == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
        cell.textLabel.text = @"city names";
        cell.detailTextLabel.text =@"loading...";
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
    //city name and country
    CityWithWeather *city= self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row];

    NSString *cityWithCountryAbrreviation = [NSString stringWithFormat:@"%@, %@", city.cityName, city.countryAbreviation];
    NSLog(@"cityWithCountryAbrreviation: %@", cityWithCountryAbrreviation);
    
    //temperature in C° and F°
    
    NSString *tempString = [NSString stringWithFormat:@"%@/%@", city.tempInCelsius, city.tempInFahrenheit];
    NSLog(@"%@", tempString);
    
    cell.detailTextLabel.text = tempString;
    cell.textLabel.text = cityWithCountryAbrreviation;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"DELETE SOME CITIES!!!");
        
        CityWithWeather *cityToDelete = self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row];
        NSLog(@"Trying to delete:%@", cityToDelete.cityName);
        
        NSInteger cityID = [cityToDelete.cityID integerValue];
        
        [self.sharedWeatherAppDataStore.citiesWithWeatherArray removeObject:self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row]];
        
        [self.sharedWeatherAppDataStore deleteSelectedCityWithID:cityID];

    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
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
        CityWithWeather *city = self.sharedWeatherAppDataStore.citiesWithWeatherArray[selectedIndexPath.row];
        
        destinationVC.cityWithWeather = city;
        
    }
    
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)unwindSegue {

    UIViewController *sourceViewController = unwindSegue.sourceViewController;
    
    if([sourceViewController isKindOfClass:[SelectCityMapViewController class]]) {
        NSLog(@"Segue coming from Map!");
    }

}


@end
