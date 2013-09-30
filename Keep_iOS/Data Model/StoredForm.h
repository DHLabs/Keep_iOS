//
//  StoredForm.h
//  Keep
//
//  Created by Sean Patno on 4/29/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepForm.h"

@interface StoredForm : NSObject

@property (nonatomic, strong) NSDictionary * formData;
@property (nonatomic, strong) KeepForm * xform;
@property (nonatomic, assign) BOOL isFinished;

@end
