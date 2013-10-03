//
//  DHSelectQuestionController.m
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHSelectQuestionController.h"

@interface DHSelectQuestionController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView * optionTable;
    NSMutableArray * labelControllers;
    NSMutableArray * selectedValues;
}
@end

@implementation DHSelectQuestionController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect rect = CGRectMake(0.0, self.labelController.view.frame.size.height, self.view.frame.size.width, 100.0);
    optionTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    optionTable.allowsMultipleSelection = self.allowMultiple;
    optionTable.allowsSelection = YES;
    optionTable.dataSource = self;
    optionTable.backgroundColor = [UIColor clearColor];
    optionTable.backgroundView = nil;
    optionTable.scrollEnabled = NO;
    optionTable.delegate = self;

    selectedValues = [NSMutableArray arrayWithCapacity:3];
    labelControllers = [NSMutableArray arrayWithCapacity:4];

    [self.scrollView addSubview:optionTable];
    [optionTable reloadData];
    rect.size.height = optionTable.contentSize.height;
    optionTable.frame = rect;
    [self resizeQuestionView];

    if( self.defaultValue ) {
        [selectedValues addObjectsFromArray:[(NSString*)self.defaultValue componentsSeparatedByString:@" "]];

        /*NSArray * values = [(NSString*)self.defaultValue componentsSeparatedByString:@" "];
        for( NSString * value in values ) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.selectAnswers indexOfObject:value] inSection:0];
            [optionTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }*/
    }

    //[optionTable reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selectLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString * value = [self.selectAnswers objectAtIndex:indexPath.row];
    if( [selectedValues containsObject:value] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    /*[cell setAccessoryType:UITableViewCellAccessoryNone];
    for (int i = 0; i < selectedIndexes.count; i++) {
        NSUInteger num = [[selectedIndexes objectAtIndex:i] intValue];

        if (num == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            // Once we find a match there is no point continuing the loop
            break;
        }
    }*/

    DHSurveyLabel * label = [self.selectLabels objectAtIndex:indexPath.row];
    DHSurveyLabelController * labelController = [[DHSurveyLabelController alloc] init];
    labelController.label = label;
    labelController.view.tag = 337;

    if( ![labelControllers containsObject:labelController] ) {
        [labelControllers addObject:labelController];
    }

    [cell.contentView addSubview:labelController.view];

    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

    return [cell.contentView viewWithTag:337].frame.size.height;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString * value = [self.selectAnswers objectAtIndex:indexPath.row];

    if( [selectedValues containsObject:value] ) {
        [selectedValues removeObject:value];
    } else {
        if( !self.allowMultiple ) {
            [selectedValues removeAllObjects];
        }
        [selectedValues addObject:value];
    }
    [tableView reloadData];
}

-(id) questionAnswer
{
    NSString * valueString = @"";

    BOOL firstDone = NO;

    for(  NSString * value in selectedValues) {
        if( firstDone ) {
            valueString = [valueString stringByAppendingFormat:@" %@", value];
        } else {
            valueString = [valueString stringByAppendingFormat:@"%@", value];
            firstDone = YES;
        }
    }

    /*for ( NSIndexPath * index in [optionTable indexPathsForSelectedRows]) {
        if( firstDone ) {
            valueString = [valueString stringByAppendingFormat:@" %@", [self.selectAnswers objectAtIndex:index.row]];
        } else {
            valueString = [valueString stringByAppendingString:[self.selectAnswers objectAtIndex:index.row]];
            firstDone = YES;
        }
    }*/

    if( [valueString isEqualToString:@""] ) {
        valueString = nil;
    }

    //NSLog(@"select answer: %@", valueString);

    return valueString;
}

@end
