//
//  RegisterFormViewController.m
//  Keep
//
//  Created by Sean Patno on 7/16/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "RegisterFormViewController.h"

#import "DHMiscUtilities.h"
#import "Registrant.h"
#import "AFNetworking.h"
#import "RegistrantViewController.h"
#import "AppearanceSettingsControllerViewController.h"
#import "SVProgressHUD.h"

@interface RegisterFormViewController () <UISearchBarDelegate, AppearanceSettingsDelegate>
{
    NSMutableArray * allData;
    NSMutableArray * shownData;
    NSString * downloadUrl;
    BOOL searching;
    BOOL sortAscending;
    NSString * sortBy;
    NSArray * showAttributes;

    int currentPage;
}
@end

@implementation RegisterFormViewController

-(void) cancelSelection
{
    [self.registrantDelegate cancelSelect];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self sortData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self saveDisplayPrefs];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if( self.useLocalList ) {
        allData = self.registerForm.registrants;
        [shownData removeAllObjects];
        [shownData addObjectsFromArray:allData];
        [self.tableView reloadData];
    }
}

-(void) sortSettings
{
    AppearanceSettingsControllerViewController * settings = [[AppearanceSettingsControllerViewController alloc] initWithStyle:UITableViewStyleGrouped];

    settings.questions = self.registerForm.questions;
    settings.settingsDelegate = self;
    settings.currentShownAttributes = showAttributes;
    settings.currentSortBy = sortBy;
    settings.sortAscending = sortAscending;

    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:settings];

    [self presentViewController:nav animated:YES completion:nil];
}

-(void) dismissWithSort:(NSString*) sortAttribute displayed:(NSArray*) shownAttributes ascending:(BOOL)ascending
{
    sortBy = sortAttribute;
    showAttributes = shownAttributes;
    sortAscending = ascending;
    
    [self sortData];
}

-(void) loadDisplayPrefs
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    sortBy = [defaults objectForKey:@"displaySortBy"];
    showAttributes = [defaults objectForKey:@"displayAttributes"];
    sortAscending = [defaults boolForKey:@"displaySortOption"];
}

-(void) saveDisplayPrefs
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:sortBy forKey:@"displaySortBy"];
    [defaults setObject:showAttributes forKey:@"displayAttributes"];
    [defaults setBool:sortAscending forKey:@"displaySortOption"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.registerForm.name;

    currentPage = 0;

    [self loadDisplayPrefs];

    shownData = [[NSMutableArray alloc] initWithCapacity:6];

    if( self.registrantDelegate ) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelection)];
    } else {

        UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(sortSettings)];

        UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newRegister)];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton,settingsButton, nil];
    }

    if( self.useLocalList ) {

        allData = self.registerForm.registrants;
        [shownData addObjectsFromArray:allData];

    } else {
        downloadUrl = [self.registerForm.downloadURL stringByReplacingOccurrencesOfString:@"repos" withString:@"data"];
        downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"xform" withString:@"json"];
        downloadUrl = [downloadUrl stringByAppendingString:@"&key=574219063edc6cec0681e2c34e38e1dc"];
        
        [self getData:downloadUrl];

        UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                            init];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Pull To Refresh"];
        [refreshControl setAttributedTitle:string];

        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    [self createSearchBar];

}

-(int) getNumItems:(NSDictionary*) dict
{
    int total = 0;
    for( id value in [dict allValues] ) {
        if( [value isKindOfClass:[NSDictionary class]] ) {
            total += [self getNumItems:value];
        } else {
            total++;
        }
    }
    return total;
}

+(NSString*) getFormattedValue:(NSString*) value
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    NSDate *date = [dateFormat dateFromString:value];

    if( !date ) {
        return value;
    }

    [dateFormat setDateFormat:@"MM/dd/yyyy"];

    return [dateFormat stringFromDate:date];
}

-(void) buildString:(NSMutableString*)string forData:(NSDictionary*)data
{
    for( id key in [data allKeys] ) {

        if( showAttributes ) {
            if( [showAttributes containsObject:key] ) {
                [string appendFormat:@"%@: ", key];

                id value = [data objectForKey:key];
                if( [value isKindOfClass:[NSDictionary class]] ) {
                    [string appendString:@"\n"];
                    [self buildString:string forData:value];
                } else {
                    [string appendFormat:@"%@\n", [RegisterFormViewController getFormattedValue:value]];
                    
                }
            }
        } else {
            [string appendFormat:@"%@: ", key];

            id value = [data objectForKey:key];
            if( [value isKindOfClass:[NSDictionary class]] ) {
                [string appendString:@"\n"];
                [self buildString:string forData:value];
            } else {
                [string appendFormat:@"%@\n", [RegisterFormViewController getFormattedValue:value]];

            }
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( allData ) {
        if( [allData count] > 0 ) {

            if( indexPath.row < [shownData count] ) {
                NSDictionary * datajson;

                datajson = ((Registrant*)[shownData objectAtIndex:indexPath.row]).registrantData;

                NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
                [self buildString:label forData:datajson];

                CGSize size = [label sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(270, 999.0f) lineBreakMode:NSLineBreakByWordWrapping];

                if (size.height < 30) {
                    size.height = 40;
                }
                
                return size.height + 20;
            }

        }
    }
    return 44.0;
}

-(void) refresh
{
    self.refreshControl.attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Refreshing..."];

    [self getData:downloadUrl];   
}

-(void) newRegister
{
    [DHMiscUtilities presentForm:self.registerForm fromController:self];
}

-(void)createSearchBar {
    //if (self.searchKey.length) {
    if (self.tableView && !self.tableView.tableHeaderView) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        //[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        self.searchDisplayController.searchResultsDelegate = self;
        self.searchDisplayController.searchResultsDataSource = self;
        //self.searchDisplayController.delegate = self;
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        searchBar.placeholder = @"Search Patients";
        searchBar.frame = CGRectMake(0, 0, 0, 44);
        self.tableView.tableHeaderView = searchBar;
    }
    //} else {
    //    self.tableView.tableHeaderView = nil;
    //}
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searching = YES;

    [shownData removeAllObjects];

    for( Registrant * reg in allData ) {
        NSDictionary * dataDict = reg.registrantData;

        for( NSString * value in [dataDict allValues] ) {
            if( [value rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                [shownData addObject:reg];
                continue;
            }
        }
    }

    [self.tableView reloadData];
}

-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [shownData removeAllObjects];
    [shownData addObjectsFromArray:allData];
    [self sortData];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searching = NO;
    [self.tableView reloadData];
}

-(void) getData:(NSString*) downloadURL
{
    allData = [[NSMutableArray alloc] init];

    NSURL *url = [self buildDownloadUrl];

    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        currentPage = 0;

        NSArray * jsonData = [responseObject objectForKey:@"data"];
        for( NSDictionary * dict in jsonData ) {
            Registrant * reg = [[Registrant alloc] init];
            reg.registrantData = [dict objectForKey:@"data"];
            [allData addObject:reg];
        }
        [shownData removeAllObjects];
        [shownData addObjectsFromArray:allData];
        [self sortData];

        if( self.refreshControl.refreshing ) {
            [self.refreshControl endRefreshing];
            self.refreshControl.attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Pull to Refresh"];
        }

        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
        NSLog(@"failure to download: %@, %@", operation.responseString, error);
    }];

}

-(NSURL*) buildDownloadUrl
{
    NSString * sortType = @"descending";
    if( sortAscending ) {
        sortType = @"ascending";
    }

    NSString * sortString = @"";
    if (sortBy) {
        sortString = [NSString stringWithFormat:@"&sort=%@", sortBy];
    }
    
    NSString * urlString = [NSString stringWithFormat:@"%@&offset=%d%@&sort_type=%@", downloadUrl, currentPage, sortString, sortType];
    NSURL *url = [NSURL URLWithString:urlString];

    return url;
}

-(void) nextPage
{
    currentPage++;

    NSURL *url = [self buildDownloadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSArray * jsonData = [JSON objectForKey:@"data"];
        for( NSDictionary * dict in jsonData ) {
            Registrant * reg = [[Registrant alloc] init];
            reg.registrantData = [dict objectForKey:@"data"];
            [allData addObject:reg];
            [shownData addObject:reg];
        }

        [self sortData];
    
        [self.tableView reloadData];

        [SVProgressHUD dismiss];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

        NSLog(@"failure to download: %@, %@", response, error);

        [SVProgressHUD dismiss];
    }];
    
    [operation start];
}

-(void) sortData
{
    if( sortBy ) {

        [shownData sortUsingComparator:^NSComparisonResult(id a, id b)
        {
            NSString * aS = [((Registrant*)a).registrantData objectForKey:sortBy];
            NSString * bS = [((Registrant*)b).registrantData objectForKey:sortBy];

            if( sortAscending ) {
                return [aS compare:bS];
            } else {
                return [bS compare:aS];
            }
        }];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [shownData count] + 1;

    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary * datajson = nil;// = [[jsonData objectAtIndex:indexPath.row] objectForKey:@"data"];

    if( indexPath.row < [shownData count] ) {
        datajson = ((Registrant*)[shownData objectAtIndex:indexPath.row]).registrantData;
    }
    
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if( datajson ) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell.textLabel.numberOfLines = [self getNumItems:datajson];

            NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
            [self buildString:label forData:datajson];

            CGSize size = [label sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(260, 999.0f) lineBreakMode:NSLineBreakByWordWrapping];

            UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, cell.frame.size.width - 10, size.height + 20)];

            textView.tag = 35;
            textView.userInteractionEnabled = NO;
            textView.font = [UIFont systemFontOfSize:16.0];
            textView.clipsToBounds = NO;
            cell.contentView.clipsToBounds = NO;
            cell.clipsToBounds = NO;
            textView.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:textView];
        }
        
    }

    if( datajson ) {
        cell.textLabel.text = nil;

        NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
        [self buildString:label forData:datajson];

        UITextView * textView = (UITextView*)[cell.contentView viewWithTag:35];

        textView.text = label;
    } else {
        UITextView * textView = (UITextView*)[cell.contentView viewWithTag:35];
        if( textView ) {
            textView.text = nil;
        }
        cell.textLabel.text = @"Next Page..";
    }


    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if( indexPath.row < [shownData count] ) {
        if( self.registrantDelegate ) {
            //TODO: finish this
            ///[self.registrantDelegate registrantSelected:[[shownData objectAtIndex:indexPath.row] objectForKey:@"data"]];;

            return;
        }

        RegistrantViewController * registerView = [[RegistrantViewController alloc] initWithStyle:UITableViewStylePlain];

        registerView.registrant = [shownData objectAtIndex:indexPath.row];
        registerView.registerForm = self.registerForm;

        registerView.server = self.server;

        [self.navigationController pushViewController:registerView animated:YES];
    } else {
        [self nextPage];
    }


    
}

@end
