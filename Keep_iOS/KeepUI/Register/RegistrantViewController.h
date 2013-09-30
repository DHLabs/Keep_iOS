//
//  RegistrantViewController.h
//  Keep
//
//  Created by Sean Patno on 7/16/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeepServer.h"
#import "KeepForm.h"
#import "Registrant.h"

@interface RegistrantViewController : UITableViewController

@property (nonatomic, assign) BOOL useLocalList;
@property (nonatomic, strong) KeepForm * registerForm;
@property (nonatomic, strong) KeepServer* server;
@property (nonatomic, strong) Registrant * registrant;

@end
