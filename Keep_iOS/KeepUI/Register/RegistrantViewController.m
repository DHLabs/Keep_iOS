//
//  RegistrantViewController.m
//  Keep
//
//  Created by Sean Patno on 7/16/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "RegistrantViewController.h"

#import "FormDataTableViewController.h"
#import "DHMiscUtilities.h"

@interface RegistrantViewController ()
{
    NSMutableArray * nonRegisterForms;
}
@end

@implementation RegistrantViewController

//TODO: add patient summary at top at some point

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Forms";

    nonRegisterForms = [[NSMutableArray alloc] init];
    for( KeepForm * form in self.server.forms ) {
        if( ![form.formType isEqualToString:@"register"] ) {
            [nonRegisterForms addObject:form];
        }
    }

    if( self.useLocalList ) {
        //data is local already
    } else {
        //download data from server
        [self.registrant downloadUserData:nonRegisterForms completion:^() {
            [self.tableView reloadData];
        }];
    }
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
    if( !nonRegisterForms ) {
        return 0;
    }

    return [nonRegisterForms count] + 1;
}

-(void) showData: (UIControl *) button withEvent: (UIEvent *) event
{
    KeepForm * form = [nonRegisterForms objectAtIndex:(button.tag - 10)];

    FormDataTableViewController * formData = [[FormDataTableViewController alloc] initWithStyle:UITableViewStylePlain];

    formData.form = form;

    [self.navigationController pushViewController:formData animated:YES];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    KeepForm * form = [nonRegisterForms objectAtIndex:indexPath.row];

    FormDataTableViewController * formData = [[FormDataTableViewController alloc] initWithStyle:UITableViewStylePlain];

    //formData.pid = self.pid;
    formData.form = form;
    //formData.pid = [self.registrant.registrantData objectForKey:@"Patient_Identification"];
    formData.pid = [self.registrant.registrantData objectForKey:@"Barcode1"];

    [self.navigationController pushViewController:formData animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

        cell.textLabel.backgroundColor = [UIColor clearColor];
        //cell.imageView.image = [UIImage imageNamed:@"formicon.png"];

        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    if( indexPath.row == [nonRegisterForms count] ) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if( [self.registerForm.registrants containsObject:self.registrant] ) {
            cell.textLabel.text = @"Remove from local list";
        } else {
            cell.textLabel.text = @"Add to local list";
        }
        cell.detailTextLabel.text = @"";
    } else {
        
        KeepForm * form = [nonRegisterForms objectAtIndex:indexPath.row];
        cell.textLabel.text = form.name;

        NSArray * data = [self.registrant.registrantFormDatas objectForKey:form.name];
        if( data ) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Submissions", [data count]];
        } else {
            cell.detailTextLabel.text = @"0 Submissions";
        }
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

    if( indexPath.row == [nonRegisterForms count] ) {

        if( [self.registerForm.registrants containsObject:self.registrant] ) {
            [self.registerForm.registrants removeObject:self.registrant];
        } else {
            [self.registerForm.registrants addObject:self.registrant];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        [self.tableView reloadData];

    } else {
        KeepForm * form = [nonRegisterForms objectAtIndex:indexPath.row];

        //TODO: will need to be fixed for groups at some point
        NSMutableDictionary * progress = [[NSMutableDictionary alloc] init];
        for( NSString * key in [self.registrant.registrantData allKeys] ) {
            NSString * path = [NSString stringWithFormat:@"/%@/%@", form.name, key];
            [progress setValue:[self.registrant.registrantData objectForKey:key] forKey:path];
        }
        form.progress = progress;

        [DHMiscUtilities presentForm:form fromController:self];
    }    
}

@end
