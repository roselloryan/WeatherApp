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
        
        [self.sharedWeatherAppDataStore fetchSelectedCities];

        [self.sharedWeatherAppDataStore getWeatherWithCompletion:^(BOOL success) {
            
            NSLog(@"WE DONE!!!");
            if (success == YES) {
                
                [self.tableView reloadData];
                NSLog(@"HELLO SUCCESS!!");
                
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
    NSString *cityName = self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row][@"name"];

    NSString *countryAbbreviation = self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row][@"sys"][@"country"];

    NSString *cityWithCountryAbrreviation = [NSString stringWithFormat:@"%@, %@", cityName, countryAbbreviation];
    
    
    //temperature in C° and F°
    
    CGFloat tempInCelsius = [self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row][@"main"][@"temp"] floatValue] -273.15;
    NSLog(@"%f", tempInCelsius);
  
    CGFloat tempInFahrenheit = (tempInCelsius * 9/5) + 32;
    NSLog(@"%f", tempInFahrenheit);
    
    NSString *tempString = [NSString stringWithFormat:@"%.0f°C/%.0f°F", roundf(tempInCelsius), roundf(tempInFahrenheit)];
    NSLog(@"%@", tempString);
    
    cell.detailTextLabel.text = tempString;
    cell.textLabel.text = cityWithCountryAbrreviation;
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"DELETE SOME CITIES!!!");
        
        NSDictionary *cityDictionary = self.sharedWeatherAppDataStore.citiesWithWeatherArray[indexPath.row];
        NSLog(@"Trying to delete:%@", cityDictionary[@"name"]);
        
        NSInteger cityID = [cityDictionary[@"id"]integerValue];
        
        [self.sharedWeatherAppDataStore deleteSelectedCityWithID:cityID];

    }
    
    [self.tableView reloadData];
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
        NSDictionary *cityDictionary = self.sharedWeatherAppDataStore.citiesWithWeatherArray[selectedIndexPath.row];
        
        destinationVC.cityDictionary = cityDictionary;
        
    }
    
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)unwindSegue {

    UIViewController *sourceViewController = unwindSegue.sourceViewController;
    
    if([sourceViewController isKindOfClass:[SelectCityMapViewController class]]) {
        NSLog(@"Segue coming from Map!");
    }

}


@end
