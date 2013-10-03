//
//  ServerListViewController.m
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "ServerListViewController.h"

#import "DataManager.h"
#import "KeepServer.h"
#import "NewFormServerController.h"
#import "FormListViewController.h"
#import "ServerSelectViewController.h"
#import "KKPasscodeSettingsViewController.h"
#import "FormSettingViewController.h"

@interface ServerListViewController ()

-(void) addServer;
-(void) goToSettings;

@end

@implementation ServerListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Form Servers";

    //UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServer)];
    //UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
 
    self.navigationItem.leftBarButtonItem = settingsButton;


    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundiphone"]];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor whiteColor];
    }

    if( [[DataManager instance].servers count] == 0 ) {
        [self addServer];
    }
}

-(void) goToSettings
{
    FormSettingViewController * settings = [[FormSettingViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:settings];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void) addServer
{
    //NewFormServerController * newForm = [[NewFormServerController alloc] initWithRoot:[NewFormServerController getRoot]];
    ServerSelectViewController * newForm = [[ServerSelectViewController alloc] initWithStyle:UITableViewStyleGrouped];

    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:newForm];

    [self presentViewController:nav animated:YES completion:nil];
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
    return [[DataManager instance].servers count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if( indexPath.row == [[DataManager instance].servers count] ) {
        cell.textLabel.text = @"Add Server...";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        KeepServer * server = [[DataManager instance].servers objectAtIndex:indexPath.row];
        cell.textLabel.text = server.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.

    if( indexPath.row == [[DataManager instance].servers count] ) {
        return NO;
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[DataManager instance].servers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( proposedDestinationIndexPath.row == [[DataManager instance].servers count] ) {
        return sourceIndexPath;
    }

    return proposedDestinationIndexPath;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if( toIndexPath.row == [[DataManager instance].servers count] ) {
        return;
    }


    NSMutableArray * servers = [DataManager instance].servers;

    id object = [servers objectAtIndex:fromIndexPath.row];
    [servers removeObjectAtIndex:fromIndexPath.row];
    [servers insertObject:object atIndex:toIndexPath.row];

}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [[DataManager instance].servers count] ) {
        return NO;
    }
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [[DataManager instance].servers count] ) {
        [self addServer];
    } else {
        KeepServer * server = [[DataManager instance].servers objectAtIndex:indexPath.row];

        FormListViewController * formList = [[FormListViewController alloc] init];

        formList.server = server;

        [self.navigationController pushViewController:formList animated:YES];
    }
}

@end
