//
//  AppearanceSettingsControllerViewController.h
//  Keep
//
//  Created by Sean Patno on 8/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppearanceSettingsDelegate <NSObject>

-(void) dismissWithSort:(NSString*) sortAttribute displayed:(NSArray*) shownAttributes ascending:(BOOL) ascending;

@end

@interface AppearanceSettingsControllerViewController : UITableViewController

@property (nonatomic, strong) NSArray * currentShownAttributes;
@property (nonatomic, strong) NSString * currentSortBy;
@property (nonatomic, assign) BOOL sortAscending;
@property (nonatomic, strong) NSArray * questions;
@property (nonatomic, assign) id<AppearanceSettingsDelegate> settingsDelegate;

@end
