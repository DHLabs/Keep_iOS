//
//  RegisterFormViewController.h
//  Keep
//
//  Created by Sean Patno on 7/16/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeepServer.h"
#import "KeepForm.h"

@protocol RegistrantSelectDelegate <NSObject>

-(void) registrantSelected:(NSDictionary*) registrant;
-(void) cancelSelect;

@end

@interface RegisterFormViewController : UITableViewController

@property (nonatomic, assign) BOOL useLocalList;
@property (nonatomic, strong) KeepServer * server;
@property (nonatomic, strong) KeepForm * registerForm;
@property (nonatomic, assign) id<RegistrantSelectDelegate> registrantDelegate;

@end
