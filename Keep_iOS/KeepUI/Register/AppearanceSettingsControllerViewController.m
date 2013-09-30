//
//  AppearanceSettingsControllerViewController.m
//  Keep
//
//  Created by Sean Patno on 8/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "AppearanceSettingsControllerViewController.h"

#import "DHFormUtilities.h"

@interface AppearanceSettingsControllerViewController ()
{
    NSMutableArray * selectedAttributes;
    NSString * sortBy;
    BOOL ascending;

    NSMutableArray * attributes;
}
@end

@implementation AppearanceSettingsControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    selectedAttributes = [[NSMutableArray alloc] init];
    attributes = [[NSMutableArray alloc] init];

    if( self.currentSortBy ) {
        sortBy = self.currentSortBy;
    } else {
        sortBy = [[self.questions objectAtIndex:0] objectForKey:@"name"];
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];

    NSArray * flatQuestions = [DHFormUtilities flatQuestionList:self.questions];
    for( NSDictionary * question in flatQuestions ) {
        if( ![[question objectForKey:@"type"] isEqualToString:@"group"] && ![DHFormUtilities isReadOnly:question] ) {
            [attributes addObject:[question objectForKey:@"name"]];
        }
    }

    if( self.currentShownAttributes ) {
        [selectedAttributes addObjectsFromArray:self.currentShownAttributes];
    } else {
        [selectedAttributes addObjectsFromArray:attributes];
    }

    if( self.sortAscending ) {
        ascending = self.sortAscending;
    } else {
        ascending = NO;
    }

    self.title = @"Display";
}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) done
{
    [self.settingsDelegate dismissWithSort:sortBy displayed:selectedAttributes ascending:ascending];
    [self cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return @"Sort By:";
    } else {
        return @"Shown Attributes:";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 1 ) {
        return 2;
    }

    return [attributes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    if( indexPath.section == 0 || indexPath.section == 2 ) {

        NSString * attribute = [attributes objectAtIndex:indexPath.row];

        if( indexPath.section == 0 ) {
            if( [sortBy isEqualToString:attribute] ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            if( [selectedAttributes containsObject:attribute] ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        cell.textLabel.text = attribute;
    } else {
        if( indexPath.row == 0 ) {
            cell.textLabel.text = @"Ascending";
            if( ascending ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = @"Descending";
            if( !ascending ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 || indexPath.section == 2 ) {
        NSString * attribute = [attributes objectAtIndex:indexPath.row];
        if( indexPath.section == 0 ) {
            sortBy = attribute;
        } else if( indexPath.section == 2 ) {
            if( [selectedAttributes containsObject:attribute] ) {
                [selectedAttributes removeObject:attribute];
            } else {
                [selectedAttributes addObject:attribute];
            }
        }
    } else {
        if( indexPath.row == 0 ) {
            ascending = YES;
        } else {
            ascending = NO;
        }
    }    
   
    [self.tableView reloadData];
}

@end
