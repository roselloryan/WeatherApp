//
//  WeatherAppTableViewController.m

#import "WeatherAppTableViewController.h"
#import "DetailWeatherViewController.h"
#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import "AddCityViewController.h"
#import "SearchViewController.h"
#import "SelectCityMapViewController.h"
#import "WeatherStyleKit.h"
#import <CoreGraphics/CoreGraphics.h>



@interface WeatherAppTableViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) WeatherAppDataStore *sharedWeatherAppDataStore;
@property (assign, nonatomic) NSInteger updatedWeatherRequests;


@property (strong, nonatomic) UIImageView *sunImageView;
@property (strong, nonatomic) UIImageView *uglySunImageView;
@property (strong, nonatomic) UIImageView *moonImageView;
@property (strong, nonatomic) UIImageView *sadMoonImageView;
@property (strong, nonatomic) UIImageView *orbImageView;
@property (assign, nonatomic) BOOL animateOrbImageView;

@end


@implementation WeatherAppTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup navigationBar appearance
    self.navigationItem.title = @"Cities";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    // setup tableViewController background appearance
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *spaceImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    spaceImageView.image = [WeatherStyleKit imageOfCanvas81];

    UIImageView *orbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height/1.75, self.view.frame.size.width, self.view.frame.size.width)];

    
    orbImageView.image = [WeatherStyleKit imageOfCanvas77];
    [spaceImageView addSubview: orbImageView];
    self.orbImageView = orbImageView;
    
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    sunImageView.image = [WeatherStyleKit imageOfCanvas82];
    [spaceImageView addSubview:sunImageView];
    self.sunImageView = sunImageView;

    UIImageView *uglySunImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    uglySunImageView.image = [WeatherStyleKit imageOfCanvas80];
    uglySunImageView.alpha = 0;
    [spaceImageView addSubview:uglySunImageView];
    self.uglySunImageView = uglySunImageView;
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    moonImageView.image = [WeatherStyleKit imageOfCanvas83];
    [spaceImageView addSubview:moonImageView];
    self.moonImageView = moonImageView;
    
    UIImageView *sadMoonImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    sadMoonImageView.image = [WeatherStyleKit imageOfCanvas79];
    sadMoonImageView.alpha = 0;
    [spaceImageView addSubview:sadMoonImageView];
    self.sadMoonImageView = sadMoonImageView;
    
    
    [self.navigationController.view addSubview:spaceImageView];
    [self.navigationController.view sendSubviewToBack:spaceImageView];

    
    // lower top row with tableViewHeader add tap gestureRecognizers to tableViewHeader
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/6)];
   
    UIView *moonEasterEggView = [[UIView alloc]initWithFrame:CGRectMake(self.tableView.tableHeaderView.frame.size.width/2, 0, self.tableView.tableHeaderView.frame.size.width/2, self.tableView.tableHeaderView.frame.size.height)];
    moonEasterEggView.userInteractionEnabled = YES;
    moonEasterEggView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *moonTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moonTapGestureRecognized:)];
    moonTapGestureRecognizer.numberOfTapsRequired = 3;
    moonTapGestureRecognizer.numberOfTouchesRequired = 2;
    [moonEasterEggView addGestureRecognizer:moonTapGestureRecognizer];
    [self.tableView.tableHeaderView addSubview: moonEasterEggView];
    
    UIView *sunEasterEggView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.tableHeaderView.frame.size.width/2, self.tableView.tableHeaderView.frame.size.height)];
    sunEasterEggView.userInteractionEnabled = YES;
    sunEasterEggView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *sunTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sunTapGestureRecognized:)];
    sunTapGestureRecognizer.numberOfTapsRequired = 3;
    sunTapGestureRecognizer.numberOfTouchesRequired = 2;
    [sunEasterEggView addGestureRecognizer:sunTapGestureRecognizer];
    [self.tableView.tableHeaderView addSubview:sunEasterEggView];
    
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
    self.navigationItem.title = @"Cities";
    self.navigationController.view.tintColor = self.tableView.tintColor;

    //animate orb!!!
    self.animateOrbImageView = YES;
    [self animateOrbImageViewPulse];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.updatedWeatherRequests = 0;
    [self updateWeatherData];
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
   
    UITableViewCell *cityCell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
   //check for visualEffectView to not keep adding views
    BOOL itDoesHaveVisualEffectView = NO;
    
    for (UIView *view in cityCell.subviews) {
        if ([view isKindOfClass:[UIVisualEffectView class]]) {
            itDoesHaveVisualEffectView = YES;
            break;
        }
    }
    
    //if no visualEffectView add one
    if (!itDoesHaveVisualEffectView) {
        
        // build and add blurEffect to tableViewCells
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = cityCell.bounds;
        visualEffectView.layer.cornerRadius = 5.0f;
        visualEffectView.layer.masksToBounds = YES;
        [cityCell addSubview:visualEffectView];
        [cityCell sendSubviewToBack:visualEffectView];
        
        // build selected backgroundView
        UIView *selectedView = [UIView new];
        selectedView.backgroundColor = [UIColor clearColor];
        cityCell.selectedBackgroundView = selectedView;
    }
    

    SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];
    
    cityCell.backgroundColor = [UIColor clearColor];
    cityCell.layer.cornerRadius = 5.0f;
    cityCell.layer.masksToBounds = YES;
    cityCell.layer.borderWidth = 0.5f;
    cityCell.layer.borderColor = [UIColor orangeColor].CGColor;
    
    NSString *cityWithCountryAbbreviation = [NSString stringWithFormat:@"%@, %@", selectedCity.cityName, selectedCity.countryName];
    NSString *tempString = [NSString stringWithFormat:@"%@ / %@", selectedCity.tempInCelsius, selectedCity.tempInFahrenheit];
    cityCell.detailTextLabel.text = tempString;
    cityCell.textLabel.text = cityWithCountryAbbreviation;
    
    return cityCell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *clearView = [[UIView alloc]init];
    clearView.backgroundColor = [UIColor clearColor];
    
    return clearView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 35;
}


-(void)updateWeatherData {
    
    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    [self.sharedWeatherAppDataStore fetchSelectedCities];
    
//    for (NSInteger i =0 ; i < self.sharedWeatherAppDataStore.selectedCitiesArray.count; i++) {
    
    if (self.updatedWeatherRequests != self.sharedWeatherAppDataStore.selectedCitiesArray.count) {
    
        SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[self.updatedWeatherRequests];
        
        [self.sharedWeatherAppDataStore getWeatherForSelectedCity:selectedCity withCompletion:^(BOOL success, NSError *error) {
            
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self.tableView reloadData];
                    NSLog(@"HELLO SUCCESS!!");
                }];
                
                self.updatedWeatherRequests += 1;
                NSLog(@" from success - self.updatedWeatherRequests: %lu", self.updatedWeatherRequests);
                [self updateWeatherData];
            }
            
            else if(!success && error) {
                
                self.updatedWeatherRequests += 1;
                NSLog(@" from !success && error - self.updatedWeatherRequests: %lu", self.updatedWeatherRequests);

                //build alertControlleror
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", error.domain] message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                
            
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self.tableView reloadData];
                    
                    [self presentViewController:alertController animated:YES
                                     completion:^{
                        // anything to do here? maybe try api again? say something witty?
                    }];
                }];
            }
        }];
    }
    else {
        // stop calling updateWeatherData.
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SelectedCity *cityToDelete = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];
        NSLog(@"Trying to delete:%@", cityToDelete.cityName);
        
        NSInteger cityID = cityToDelete.cityID;
        
        [self.sharedWeatherAppDataStore deleteSelectedCityWithID:cityID];
        
    }
    [self.tableView reloadData];
}



#pragma mark - Easter Egg Gesture Handlers


-(IBAction)moonTapGestureRecognized:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.sadMoonImageView.alpha == 0) {
            [UIImageView animateWithDuration:2 animations:^{
                self.moonImageView.alpha = 0;
                self.sadMoonImageView.alpha = 1;
            } completion:^(BOOL finished) {
                NSLog(@"finished moon easter egg animation!");
            }];
        }
        else {
            [UIImageView animateWithDuration:2 animations:^{
                self.moonImageView.alpha = 1;
                self.sadMoonImageView.alpha = 0;
            } completion:^(BOOL finished) {
                NSLog(@"finished moon easter egg animation!");
            }];
        }
    }
}


-(IBAction)sunTapGestureRecognized:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.uglySunImageView.alpha == 0) {
            [UIImageView animateWithDuration:2 animations:^{
                self.sunImageView.alpha = 0;
                self.uglySunImageView.alpha = 1;
            } completion:^(BOOL finished) {
                NSLog(@"finished SUN easter egg animation!");
            }];
        }
        else {
            [UIImageView animateWithDuration:2 animations:^{
                self.sunImageView.alpha = 1;
                self.uglySunImageView.alpha = 0;
            } completion:^(BOOL finished) {
                NSLog(@"finished SUN easter egg animation!");
            }];
        }
    }
}



#pragma mark - Background Animations


-(void)animateOrbImageViewPulse {
    
    [UIImageView animateWithDuration:3 animations:^{
        
        self.orbImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        
        [UIImageView animateWithDuration:4 delay:0 options:0 animations:^{
        
            self.orbImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
           
            if (self.animateOrbImageView == YES) {
                
                [self animateOrbImageViewPulse];
            }
            else {
                // don't start pulse again.
            }
        }];
    }];
}

-(void)makeOrbImageViewSpin:(UIImageView *)orbImageView {
    
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        orbImageView.transform = CGAffineTransformRotate(orbImageView.transform, M_PI/2);
    } completion:^(BOOL finished) {
        [self makeOrbImageViewSpin:orbImageView];
    }];
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //stop orb animation
    self.animateOrbImageView = NO;
    
    if([segue.identifier isEqualToString:@"addCitySegue"]) {
        
        AddCityViewController *destinationVC = segue.destinationViewController;
        destinationVC.allCitiesArray = self.allCitiesArray;
    }
    
    else if ([segue.identifier isEqualToString:@"searchViewSegue"]) {
        SearchViewController *destinationVC = segue.destinationViewController;
        destinationVC.allCitiesArray = self.allCitiesArray;
    }
    
    // pass city dictionary forwrd to detailWeatherViewController
    else if([segue.identifier isEqualToString:@"detailWeatherViewControllerSegue"]) {
        
        DetailWeatherViewController *destinationVC = segue.destinationViewController;
        
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


@end
