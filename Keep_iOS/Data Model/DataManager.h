//
//  DataManager.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepServer.h"

@interface DataManager : NSObject<NSXMLParserDelegate>


@property (nonatomic, strong) NSMutableArray * servers;
@property (nonatomic, strong) NSMutableArray * storedForms;

+(DataManager*) instance;
-(void)saveDataToFilesystem;
-(void)loadDataFromFilesystem;
- (NSString *)databasePath;
-(KeepServer*) serverForName:(NSString *)serverName;
-(void) addServer:(KeepServer*) server atIndex:(NSInteger)index success:(void (^)(void)) success failure:(void (^)(void)) failure;

@end
