//
//  MainWeatherViewController.m


#import "MainWeatherViewController.h"
#import "DetailWeatherViewController.h"
#import "WeatherAppDataStore.h"
#import "APIClient.h"
#import "SearchViewController.h"
#import "SelectCityMapViewController.h"
#import "WeatherStyleKit.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CityCellTableViewCell.h"

@interface MainWeatherViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) WeatherAppDataStore *sharedWeatherAppDataStore;

@property (assign, nonatomic) NSInteger updatedWeatherRequests;

@property (strong, nonatomic) UIImageView *sunImageView;
@property (strong, nonatomic) UIImageView *uglySunImageView;
@property (strong, nonatomic) UIImageView *moonImageView;
@property (strong, nonatomic) UIImageView *sadMoonImageView;
@property (strong, nonatomic) UIImageView *orbImageView;

@property (assign, nonatomic) BOOL animateOrbImageView;


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addCityButton;




@end



@implementation MainWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    
    //     build and add blurEffect to addCityButton
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame = self.addCityButton.bounds;
    visualEffectView.layer.cornerRadius = 5.0f;
    visualEffectView.layer.masksToBounds = YES;
    visualEffectView.userInteractionEnabled = NO;
    visualEffectView.exclusiveTouch = NO;
    
    [self.addCityButton addSubview:visualEffectView];
    [self.addCityButton sendSubviewToBack:visualEffectView];
    
    
    self.addCityButton.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.1];
    self.addCityButton.layer.cornerRadius = 5.0f;
    self.addCityButton.layer.masksToBounds = YES;
    self.addCityButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
    
    
    // tableView appearance
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.layer.masksToBounds = YES;
    
    // make backgroundImageView interactable. yup... otherwise subviews won't be interactable. 
    self.backgroundImageView.userInteractionEnabled = YES;
    
    // setup background appearance
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
    
    [self.backgroundImageView addSubview:spaceImageView];

    
    // add sun and moon and easter egg gesture recognizers
    UIView *moonEasterEggView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 20, self.view.frame.size.width/2, 150)];
    moonEasterEggView.userInteractionEnabled = YES;
    moonEasterEggView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *moonTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moonTapGestureRecognized:)];
    moonTapGestureRecognizer.numberOfTapsRequired = 3;
    moonTapGestureRecognizer.numberOfTouchesRequired = 2;
    [moonEasterEggView addGestureRecognizer:moonTapGestureRecognizer];
    [self.backgroundImageView addSubview: moonEasterEggView];
    [self.backgroundImageView bringSubviewToFront:moonEasterEggView];
    
    UIView *sunEasterEggView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width/2, 150)];
    sunEasterEggView.userInteractionEnabled = YES;
    sunEasterEggView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *sunTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sunTapGestureRecognized:)];
    sunTapGestureRecognizer.numberOfTapsRequired = 3;
    sunTapGestureRecognizer.numberOfTouchesRequired = 2;
    sunTapGestureRecognizer.delegate = self;
    [sunEasterEggView addGestureRecognizer:sunTapGestureRecognizer];
    [self.backgroundImageView addSubview:sunEasterEggView];
    [self.backgroundImageView bringSubviewToFront:sunEasterEggView];
    
    
    
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
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    
    return self.sharedWeatherAppDataStore.selectedCitiesArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   CityCellTableViewCell *cityCell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
    SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];

    // set temp string if updated (prevents string from saying "null")
    if (selectedCity.tempInCelsius == nil) {
        
        NSString *blankString = @"";
        cityCell.tempLabel.text = blankString;
    }
    else {
        
        NSString *tempString = [NSString stringWithFormat:@"%@ / %@", selectedCity.tempInCelsius, selectedCity.tempInFahrenheit];
        cityCell.tempLabel.text = tempString;
    }
    
    NSString *cityWithCountryAbbreviation = [NSString stringWithFormat:@"%@, %@", selectedCity.cityName, selectedCity.countryName];
    cityCell.cityNameLabel.text = cityWithCountryAbbreviation;
    
    
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SelectedCity *cityToDelete = self.sharedWeatherAppDataStore.selectedCitiesArray[indexPath.section];
        
        NSInteger cityID = cityToDelete.cityID;
        
        [self.sharedWeatherAppDataStore deleteSelectedCityWithID:cityID];
        
    }
    [self.tableView reloadData];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(void)updateWeatherData {
    
    self.sharedWeatherAppDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
    [self.sharedWeatherAppDataStore fetchSelectedCities];

    
    if (self.updatedWeatherRequests != self.sharedWeatherAppDataStore.selectedCitiesArray.count && self.updatedWeatherRequests < self.sharedWeatherAppDataStore.selectedCitiesArray.count) {
        
        SelectedCity *selectedCity = self.sharedWeatherAppDataStore.selectedCitiesArray[self.updatedWeatherRequests];
        
        [self.sharedWeatherAppDataStore getWeatherForSelectedCity:selectedCity withCompletion:^(BOOL success, NSError *error) {
            
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self.tableView reloadData];
                }];
                
                self.updatedWeatherRequests += 1;
//                NSLog(@" from success - self.updatedWeatherRequests: %lu", self.updatedWeatherRequests);
                [self updateWeatherData];
            }
            
            else if(!success && error) {
                
                self.updatedWeatherRequests += 1;
//                NSLog(@" from !success && error - self.updatedWeatherRequests: %lu", self.updatedWeatherRequests);
                
                if ([error.domain isEqualToString:@"NSCocoaErrorDomain"]) {
                    
                    //build failed update alertController
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Some cities' weather could not be updated, but we'll keep trying until we get them all." preferredStyle:UIAlertControllerStyleAlert];
                    
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
                
                else {
                    //build alertControllers
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
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
            }
        }];
    }
    
    else {
        // stop calling updateWeatherData.
    }
}


#pragma mark - Easter Egg Gesture Handlers


-(IBAction)moonTapGestureRecognized:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.sadMoonImageView.alpha == 0) {
            [UIImageView animateWithDuration:2 animations:^{
                self.moonImageView.alpha = 0;
                self.sadMoonImageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }
        else {
            [UIImageView animateWithDuration:2 animations:^{
                self.moonImageView.alpha = 1;
                self.sadMoonImageView.alpha = 0;
            } completion:^(BOOL finished) {
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
            }];
        }
        else {
            [UIImageView animateWithDuration:2 animations:^{
                self.sunImageView.alpha = 1;
                self.uglySunImageView.alpha = 0;
            } completion:^(BOOL finished) {
            }];
        }
    }
}


#pragma mark - Background Animations


-(void)animateOrbImageViewPulse {
    
    [UIImageView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.orbImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        
        [UIImageView animateWithDuration:4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
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


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //stop orb animation
    self.animateOrbImageView = NO;
    
    if ([segue.identifier isEqualToString:@"searchViewSegue"]) {
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
    }
}


@end
