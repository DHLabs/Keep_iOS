//
//  Registrant.h
//  Keep
//
//  Created by Sean Patno on 8/8/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Registrant : NSObject

@property (nonatomic, strong) NSMutableDictionary * registrantFormDatas;
@property (nonatomic, strong) NSDictionary * registrantData;

-(void) downloadUserData:(NSArray*) forms completion:(void (^)(void))completionBlock;

@end
