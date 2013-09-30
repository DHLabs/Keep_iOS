//
//  DHNetworkUtilities.h
//  Keep
//
//  Created by Sean Patno on 5/15/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepServer.h"

@interface DHNetworkUtilities : NSObject

+(void) downloadXML:(NSString*)url to:(NSString*)filepath success:(void(^)(void))success failure:(void(^)(void)) failure;

+(void) downloadFile:(NSString*)url to:(NSString*)filepath success:(void(^)(void))success failure:(void(^)(void)) failure;

@end
