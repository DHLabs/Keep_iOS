//
//  KeepForm.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepForm : NSObject

@property (nonatomic, strong) NSString * downloadURL;
@property (nonatomic, strong) NSString * manifestURL;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * formID;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * formPath;
@property (nonatomic, strong) NSDictionary * progress;
@property (nonatomic, strong) NSString * serverName;
@property (nonatomic, strong) NSString * formType;
@property (nonatomic, strong) NSArray * questions;

//For Patient List/Registrant List
@property (nonatomic, strong) NSMutableArray * registrants;

@end
