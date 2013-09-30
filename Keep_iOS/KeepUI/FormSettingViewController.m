//
//  FormSettingViewController.m
//  Keep
//
//  Created by Sean Patno on 6/9/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "FormSettingViewController.h"

#import "KKPasscodeSettingsViewController.h"
//#import "KeepWebViewController.h"

@interface FormSettingViewController ()

-(void) done;

@end

@implementation FormSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.navigationItem.rightBarButtonItem = doneButton;

    self.title = @"Settings";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) done
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if( indexPath.row == 0 ) {
        cell.textLabel.text = @"Passcode Settings";
    } else if( indexPath.row == 1 ) {
        cell.textLabel.text = @"Keep Web View";
    } else {
        cell.textLabel.text = @"Update App";
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 ) {
        //passcode lock
        KKPasscodeSettingsViewController * passcodeSettings = [[KKPasscodeSettingsViewController alloc] init];

        [self.navigationController pushViewController:passcodeSettings animated:YES];
    } else if( indexPath.row == 1 ) {
        //keep web view
        //KeepWebViewController * keep = [[KeepWebViewController alloc] init];
        //[self.navigationController pushViewController:keep animated:YES];
    } else {
        NSURL * url = [NSURL URLWithString:@"http://distributedhealth.s3-website-us-east-1.amazonaws.com/"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
