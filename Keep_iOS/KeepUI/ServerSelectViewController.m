//
//  ServerSelectViewController.m
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "ServerSelectViewController.h"

#import "NewFormServerController.h"
#import "KKPasscodeSettingsViewController.h"

@interface ServerSelectViewController ()

@end

@implementation ServerSelectViewController

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

    self.title = @"Select Server";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSString * imageName = @"backgroundshort.png";
    if( [UIScreen mainScreen].bounds.size.height > 600 ) {
        NSLog(@"ipad");
        imageName = @"backgroundipad.png";
    } else if( [UIScreen mainScreen].bounds.size.height > 480 ) {
        NSLog(@"iphone 5");
        imageName = @"backgroundtall.png";
    } else {
        NSLog(@"iphone");
    }

    UIImage* image = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setFrame:self.tableView.frame];

    self.tableView.backgroundView = imageView;
    self.tableView.backgroundColor = [UIColor clearColor];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                          action:@selector(cancel)];
    id first = [[NSUserDefaults standardUserDefaults] objectForKey:@"first"];
    if( !first ) {
        //show passcode settings
        //TODO:
        //KKPasscodeSettingsViewController * passcodeSettings = [[KKPasscodeSettingsViewController alloc] init];

        //[self.navigationController pushViewController:passcodeSettings animated:YES];

        //[[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:@"first"];
    }

}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if( indexPath.row == 0 ) {
        cell.textLabel.text = @"Keep";
    } else if( indexPath.row == 1 ) {
        cell.textLabel.text = @"Formhub";
    } else {
        cell.textLabel.text = @"Other";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFormServerController * newController = [[NewFormServerController alloc] initWithStyle:UITableViewStyleGrouped];

    if( indexPath.row == 0 ) {
        newController.serverType = KeepServerType;
    } else if( indexPath.row == 1) {
        newController.serverType = FormHubServerType;
    } else {
        newController.serverType = CustomServerType;
    }

    [self.navigationController pushViewController:newController animated:YES];
}

@end
