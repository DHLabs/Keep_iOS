//
//  NewFormServerController.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeepServer.h"

enum ServerType {
    KeepServerType,
    FormHubServerType,
    CustomServerType
};

@interface NewFormServerController : UITableViewController

@property (nonatomic, assign) enum ServerType serverType;

@end
