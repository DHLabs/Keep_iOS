//
//  FormDownloader.h
//  Keep
//
//  Created by Sean Patno on 7/29/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepForm.h"

@interface FormDownloader : NSObject

+(void) downloadForm:(KeepForm*)form completion:(void (^)(void)) completion failure:(void (^)(NSError * error)) failure;

@end
