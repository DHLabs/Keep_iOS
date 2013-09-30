//
//  FormDataTableViewController.h
//  Keep
//
//  Created by Sean Patno on 5/31/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeepForm.h"

@interface FormDataTableViewController : UITableViewController

@property (nonatomic, strong) KeepForm * form;
@property (nonatomic, strong) NSString * pid;

@end
