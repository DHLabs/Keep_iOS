//
//  XFormJSONConverter.h
//  Keep
//
//  Created by Sean Patno on 2/11/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFormJSONConverter : NSObject 

+(id) JSONFormFromXMLString:(NSString*) xml;
+(id) JSONFormFromXMLPath:(NSString*) path;

@end
