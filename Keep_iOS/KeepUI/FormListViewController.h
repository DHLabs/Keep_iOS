//
//  FormListViewController.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHQDViewController.h"
#import "KeepServer.h"
#import "DHSurveyViewController.h"

@interface FormListViewController : UITableViewController <DHDQViewDelegate,DHSurveyDelegate>

@property (nonatomic, strong) KeepServer * server;

@end
