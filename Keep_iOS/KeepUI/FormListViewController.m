//
//  FormListViewController.m
//  iODK
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "FormListViewController.h"

#import "KeepForm.h"
#import "DHFormUtilities.h"
#import "SVProgressHUD.h"
#import "FormDataTableViewController.h"
#import "DHMiscUtilities.h"
#import "DataManager.h"
#import "RegisterFormViewController.h"

#import "SavedFormsViewController.h"

@interface FormListViewController () //<DHSurveyDelegate>
-(void) showData: (UIControl *) button withEvent: (UIEvent *) event;

@end

@implementation FormListViewController

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

    self.title = self.server.name;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundiphone"]];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Pull To Refresh"];
    [refreshControl setAttributedTitle:string];

    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self refresh];
    //[self.refreshControl beginRefreshing];
}

-(void) hideRefreshControl
{
    if( self.refreshControl.refreshing ) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Pull to Refresh"];
    }
}

-(void) refresh
{
    self.refreshControl.attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Refreshing..."];

    //redownload forms
    KeepServer *server = [[KeepServer alloc] init];
    server.serverURL = self.server.serverURL;
    server.name = self.server.name;
    server.isKeep = self.server.isKeep;
    server.storedForms = self.server.storedForms;

    NSArray * __block registrants = nil;
    for( KeepForm * form in self.server.forms ) {
        if ([form.formType isEqualToString:@"register"]) {
            registrants = form.registrants;
            break;
        }
    }

    NSInteger serverIndex = [[DataManager instance].servers indexOfObject:self.server];

    [[DataManager instance] addServer:server atIndex:serverIndex success:^() {

        [[DataManager instance].servers removeObject:self.server];
        self.server = server;
        [self hideRefreshControl];
        [self.tableView reloadData];

        [DHMiscUtilities downloadFormsForServer:server completion:^() {

            for( KeepForm * form in server.forms ) {
                if ([form.formType isEqualToString:@"register"]) {
                    [form.registrants addObjectsFromArray:registrants];
                    break;
                }
            }

        }];
        [DHFormUtilities sendStoredForms:self.server];

    } failure:^() {

        [self hideRefreshControl];
        NSLog(@"failure to refresh");
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.server ) {
        return [self.server.forms count] + 2;
    }
    return 0;
}

-(void) showData: (UIControl *) button withEvent: (UIEvent *) event
{
    KeepForm * form = [self.server.forms objectAtIndex:(button.tag - 10)];
     
     FormDataTableViewController * formData = [[FormDataTableViewController alloc] initWithStyle:UITableViewStylePlain];

     formData.form = form;

     [self.navigationController pushViewController:formData animated:YES];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    KeepForm * form = [self.server.forms objectAtIndex:indexPath.row];

    FormDataTableViewController * formData = [[FormDataTableViewController alloc] initWithStyle:UITableViewStylePlain];

    formData.form = form;

    [self.navigationController pushViewController:formData animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.imageView.image = [UIImage imageNamed:@"formicon.png"];

    }

    if( self.server.isKeep ) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    if( indexPath.row == [self.server.forms count] ) {
        cell.textLabel.text = @"Saved Forms";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if( indexPath.row == [self.server.forms count] + 1 ) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Saved Registrants";
    } else {
        KeepForm * form = [self.server.forms objectAtIndex:indexPath.row];
        cell.textLabel.text = form.name;
    }
        
    return cell;
}

-(void) formWasSubmitted
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) surveyDidCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) survey:(KeepForm*) survey didFinishWithAnswers:(NSDictionary*)answers
{
    //TODO:
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [self.server.forms count] ) {
        SavedFormsViewController * savedForms = [[SavedFormsViewController alloc] initWithStyle:UITableViewStylePlain];
        savedForms.server = self.server;
        [self.navigationController pushViewController:savedForms animated:YES];
    } else if( indexPath.row == [self.server.forms count] + 1 ) {

        //get the register form;
        KeepForm * registerForm = nil;
        for( KeepForm * form in self.server.forms ) {
            if( [form.formType isEqualToString:@"register"] ) {
                registerForm = form;
                break;
            }
        }

        if( registerForm ) {
            RegisterFormViewController * registerView = [[RegisterFormViewController alloc] initWithStyle:UITableViewStylePlain];
            registerView.server = self.server;
            registerView.registerForm = registerForm;
            registerView.useLocalList = YES;
            [self.navigationController pushViewController:registerView animated:YES];
        } else {
            NSLog(@"what the hell?");
        }

    } else {
        KeepForm * form = [self.server.forms objectAtIndex:indexPath.row];

        if( [form.formType isEqualToString:@"register"] ) {
            RegisterFormViewController * registerView = [[RegisterFormViewController alloc] initWithStyle:UITableViewStylePlain];
            registerView.server = self.server;
            registerView.registerForm = form;
            [self.navigationController pushViewController:registerView animated:YES];
        } else {
            form.progress = nil;
            [DHMiscUtilities presentForm:form fromController:self];
        }
    }    

    /*
    FormDataTableViewController * formData = [[FormDataTableViewController alloc] initWithStyle:UITableViewStylePlain];
    //NSLog(@"tag num: %d", button.tag -10);

    formData.form = form;

    [self.navigationController pushViewController:formData animated:YES];
    return;*/    
}

@end
