//
//  DHDateTimeQuestionControllerViewController.m
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHDateTimeQuestionControllerViewController.h"

#import "DateInputTableViewCell.h"

@interface DHDateTimeQuestionControllerViewController () <UITableViewDataSource, UITableViewDelegate,DateInputTableViewCellDelegate>
{
    UITableView * dateTable;
    DateInputTableViewCell * dateInputCell;
}

@end

@implementation DHDateTimeQuestionControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CGRect rect = CGRectMake(0.0, self.labelController.view.frame.size.height, self.view.frame.size.width, 100.0);
    dateTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    dateTable.allowsSelection = YES;
    dateTable.dataSource = self;
    dateTable.backgroundColor = [UIColor clearColor];
    dateTable.backgroundView = nil;
    dateTable.scrollEnabled = NO;
    dateTable.delegate = self;

    [self.scrollView addSubview:dateTable];
    [dateTable reloadData];
    rect.size.height = dateTable.contentSize.height;
    dateTable.frame = rect;
    [self resizeQuestionView];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)tableViewCell:(DateInputTableViewCell *)cell didEndEditingWithDate:(NSDate *)value
{
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    if( self.pickerMode == UIDatePickerModeTime ) {
        format.dateFormat = @"HH:mm:ss";
    } else if(self.pickerMode == UIDatePickerModeDateAndTime) {
        format.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
    } else {
        format.dateFormat = @"MMM dd, yyyy";
    }

    cell.textLabel.text = [format stringFromDate:value];

    [cell setNeedsDisplay];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( !dateInputCell ) {
        dateInputCell = [[DateInputTableViewCell alloc] init];
        dateInputCell.delegate = self;
        dateInputCell.datePickerMode = self.pickerMode;
        dateInputCell.dateValue = [NSDate date];
        if( self.defaultValue ) {
            NSDateFormatter * format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";
            NSDate * date = [format dateFromString:self.defaultValue];
            NSLog(@"set default value: %@", date);
            [dateInputCell setDateValue:date];
            dateInputCell.dateValue = date;
            [dateTable reloadData];
        }
        dateInputCell.textLabel.textColor = [UIColor blackColor];
    }

    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    if( self.pickerMode == UIDatePickerModeTime ) {
        format.dateFormat = @"HH:mm a";
    } else if(self.pickerMode == UIDatePickerModeDateAndTime) {
        format.dateFormat = @"HH':'mm a MMM dd, yyyy";
    } else {
        format.dateFormat = @"MMM dd, yyyy";
    }

    dateInputCell.textLabel.text = [format stringFromDate:dateInputCell.dateValue];

    return dateInputCell;
}

-(void) questionDidShow
{
    [dateInputCell setSelected:YES];
}

-(void) questionWillDisappear
{
    [dateInputCell resignFirstResponder];
}

-(id) questionAnswer
{
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";

    return [format stringFromDate:dateInputCell.dateValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
