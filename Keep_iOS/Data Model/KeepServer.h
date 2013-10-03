//
//  KeepServer.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepServer : NSObject

@property (nonatomic, strong) NSString * serverURL;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray * forms;
@property (nonatomic, assign) BOOL isKeep;
@property (nonatomic, strong) NSMutableArray * storedForms;

//TODO: in the future, add authentication stuff


@end
