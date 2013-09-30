//
//  FormListViewController.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeepServer.h"

@interface FormListViewController : UITableViewController

@property (nonatomic, strong) KeepServer * server;

@end
