//
//  DHMiscUtilities.h
//  Keep
//
//  Created by Sean Patno on 6/26/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepForm.h"
#import "KeepServer.h"
#import "StoredForm.h"

@interface DHMiscUtilities : NSObject

+(void) presentForm:(KeepForm *)form fromController:(UIViewController*) controller;
+(void) presentForm:(KeepForm *)form fromController:(UIViewController *)controller withStored:(StoredForm*)storedForm;

+(void) downloadForm:(KeepForm *)form completion:(void (^)(void)) completion;

+(void) downloadFormsForServer:(KeepServer*) server completion:(void (^)(void))completion;

@end
