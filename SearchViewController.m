//
//  SearchViewController.m


#import "SearchViewController.h"
#import "WeatherStyleKit.h"
#import "WeatherAppDataStore.h"
#import "PossibleCity.h"
#import "SelectCityMapViewController.h"


@interface SearchViewController () <UITableViewDelegate,  UISearchBarDelegate, UITableViewDataSource>


@property (strong, nonatomic) NSArray *possibleCitiesFromTextInput;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@end


@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // make tableview clear
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // setup background images
    UIImageView *spaceImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    spaceImageView.image = [WeatherStyleKit imageOfCanvas81];
    
    UIImageView *orbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height/1.75, self.view.frame.size.width, self.view.frame.size.width)];
    orbImageView.image = [WeatherStyleKit imageOfCanvas77];
    [spaceImageView addSubview: orbImageView];
    
    UIImageView *sunImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    sunImageView.image = [WeatherStyleKit imageOfCanvas82	];
    [spaceImageView addSubview:sunImageView];
    
    UIImageView *moonImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    moonImageView.image = [WeatherStyleKit imageOfCanvas83];
    [spaceImageView addSubview:moonImageView];
    
    UIView *blackShadeView = [[UIView alloc]initWithFrame:self.view.bounds];
    blackShadeView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
    
    [spaceImageView addSubview:blackShadeView];
    [self.view addSubview:spaceImageView];
    [self.view sendSubviewToBack:spaceImageView];
    
    // configure searchBar apperance
    self.searchBar.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.9];
    self.searchBar.backgroundImage = [UIImage new];
    self.searchBar.layer.masksToBounds = YES;
    self.searchBar.layer.borderWidth = 0.5f;
    self.searchBar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    // make text typing color white
    NSArray *classArray = [NSArray arrayWithObject:[UISearchBar class]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:classArray] setTextColor:[UIColor whiteColor]];
    
    // observe keyboard to adjust tableView bottom constraint
    [self observeKeyboard];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // initialize empty array for possibleCitiesArrayOfMKAnnotations
    self.possibleCitiesArrayOfMKAnnotations = [[NSMutableArray alloc]init];
    
    // deselected rows if returning from map screen
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if(selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSPredicate *searchPredidcate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", searchText];
    
    NSArray *searchResultsArray = [self.allCitiesArray filteredArrayUsingPredicate:searchPredidcate];
    
    self.possibleCitiesFromTextInput = searchResultsArray;
    
    [self.tableView reloadData];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSValue *keyboardFrame = [userInfoDictionary valueForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[userInfoDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    CGRect keyboardFrameRect = [keyboardFrame CGRectValue];
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    
    self.tableViewBottomConstraint.constant = -keyboardHeight;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


-(void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfoDictionary = [notification userInfo];

    NSTimeInterval animationDuration = [[userInfoDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    self.tableViewBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *searchFieldString = self.searchBar.text;
    [self checkAndMapOrSaveForCityNamed:searchFieldString];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.possibleCitiesFromTextInput.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCityCell" forIndexPath:indexPath];

    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    NSDictionary *cityDictionary = self.possibleCitiesFromTextInput[indexPath.row];
    
    cell.textLabel.textColor = [[UIColor cyanColor]colorWithAlphaComponent:0.8];
    cell.textLabel.text = cityDictionary[@"name"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *cityDictionary = self.possibleCitiesFromTextInput[indexPath.row];
    NSString *cityName = cityDictionary[@"name"];
    
    [self checkAndMapOrSaveForCityNamed:cityName];
}


-(void)checkAndMapOrSaveForCityNamed:(NSString *)cityName {
    
    NSMutableArray *possibleCitiesArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *cityDictionary in self.allCitiesArray) {
        
        if([[cityDictionary objectForKey:@"name"] isEqualToString: cityName]) {
            
            [possibleCitiesArray addObject:cityDictionary];
        }
    }
    
    if(possibleCitiesArray.count > 1) {
        // put pins on a map and ask user to pick which city
        //build array of possible city objects conforming to MKAnnotation protocol
        
        for(NSDictionary *cityDictionary in possibleCitiesArray) {
            
            NSString *cityNameAndCountry = [NSString stringWithFormat:@"%@, %@", cityDictionary[@"name"],cityDictionary[@"country"]];
            
            CLLocationCoordinate2D newCityCoordinate = CLLocationCoordinate2DMake([cityDictionary[@"coord"][@"lat"] floatValue], [cityDictionary[@"coord"][@"lon"] floatValue]);
            
            PossibleCity *newCity = [[PossibleCity alloc]initWithCoordinate:newCityCoordinate andTitle:cityNameAndCountry];
            newCity.cityDictionary = cityDictionary;
            
            [self.possibleCitiesArrayOfMKAnnotations addObject:newCity];
        }
        
        //segue to SelectCityMapViewController
        [self performSegueWithIdentifier:@"selectCityFromMapSegue" sender:nil];
    }
    
    // just one matching city
    else if(possibleCitiesArray.count == 1) {
        
        WeatherAppDataStore *sharedDataStore = [WeatherAppDataStore sharedWeatherAppDataStore];
        
        // check if trying to save duplpicate city
        if ([sharedDataStore checkForDuplicateCityID:[possibleCitiesArray[0][@"_id"] integerValue]]) {
            
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        // add a check for duplicate city
        SelectedCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedCity" inManagedObjectContext:sharedDataStore.managedObjectContext];
        
        newCity.cityName = possibleCitiesArray[0][@"name"];
        newCity.countryName = possibleCitiesArray[0][@"country"];
        newCity.cityID = [possibleCitiesArray[0][@"_id"] integerValue];
        newCity.lat = [possibleCitiesArray[0][@"coord"][@"lat"] floatValue];
        newCity.lon = [possibleCitiesArray[0][@"coord"][@"lon"] floatValue];
        newCity.updated = nil;
        newCity.dateSelected = [NSDate date].timeIntervalSinceReferenceDate;
        
        [sharedDataStore saveContext];
        
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    else {
        
        UIAlertController *noMatchAlert = [UIAlertController alertControllerWithTitle:@"No Match" message:@"No Matching city cound. \n Please check cpelling and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [noMatchAlert addAction:okAction];
        [self presentViewController:noMatchAlert animated:YES completion:nil];
    }
}


#pragma mark - Navigation

 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.view endEditing:YES];
    
    NSIndexPath * selectedIndexPath = self.tableView.indexPathForSelectedRow;
    NSDictionary *cityDictionary = self.possibleCitiesFromTextInput[selectedIndexPath.row];
    NSString *cityName = cityDictionary[@"name"];
    
    SelectCityMapViewController *destinationVC = segue.destinationViewController;
    destinationVC.cityName = cityName;
    destinationVC.possibleCitiesArrayOfMKAnnotations = self.possibleCitiesArrayOfMKAnnotations;
}


@end
