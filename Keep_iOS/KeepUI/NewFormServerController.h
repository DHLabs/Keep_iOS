//
//  NewFormServerController.h
//  iODK
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickDialogController.h"
#import "ODKServer.h"

@interface NewFormServerController : QuickDialogController

-(void) submitServer:(QElement*)element;
+(QRootElement*) getRootForType:(int) type;
+ (BOOL) validateUrl: (NSString *) candidate;

@end
