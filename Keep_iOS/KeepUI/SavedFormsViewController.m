//
//  SavedFormsViewController.m
//  Keep
//
//  Created by Sean Patno on 6/27/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "SavedFormsViewController.h"

#import "DHMiscUtilities.h"
#import "DataManager.h"
#import "KeepForm.h"
#import "StoredForm.h"

@interface SavedFormsViewController ()
{
    NSMutableArray * savedForms;
}
@end

@implementation SavedFormsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Saved Forms";

    savedForms = [[NSMutableArray alloc] initWithCapacity:3];

    for( StoredForm * form in self.server.storedForms ) {
        if( !form.isFinished ) {
            [savedForms addObject:form];
        }
    }

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    savedForms = [[NSMutableArray alloc] initWithCapacity:3];

    for( StoredForm * form in self.server.storedForms ) {
        if( !form.isFinished ) {
            [savedForms addObject:form];
        }
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
    return [savedForms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.numberOfLines = 6;
    }

    StoredForm * form = [savedForms objectAtIndex:indexPath.row];
    cell.textLabel.text = form.xform.name;

    cell.detailTextLabel.text = [self stringFromAnswers: form.formData];

    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

-(NSString*) stringFromAnswers:(NSDictionary*) answers
{
    NSMutableString * string = [[NSMutableString alloc] init];

    for( NSString * key in [answers allKeys] ) {
        id answer = [answers objectForKey:key];

        [string appendFormat:@"%@: %@,  ", [[key componentsSeparatedByString:@"/"] lastObject], [answer description]];
    }

    return string;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        StoredForm * storedForm = [savedForms objectAtIndex:indexPath.row];
        [self.server.storedForms removeObject:storedForm];
        [savedForms removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoredForm * storedForm = [savedForms objectAtIndex:indexPath.row];
    KeepForm * form = storedForm.xform;
    form.progress = storedForm.formData;
    [DHMiscUtilities presentForm:form fromController:self withStored:storedForm];
}

@end
