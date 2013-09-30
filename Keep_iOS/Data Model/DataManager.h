//
//  DataManager.h
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeepServer.h"

@interface DataManager : NSObject<NSXMLParserDelegate> {
    NSString * xml;
    KeepServer * newServer;
    NSInteger indexToAdd;
    void (^addSuccess)(void);
    void (^addFailure)(void);
}

@property (nonatomic, strong) NSMutableArray * servers;
@property (nonatomic, strong) NSMutableArray * storedForms;

+(DataManager*) instance;
-(void)saveDataToFilesystem;
-(void)loadDataFromFilesystem;
- (NSString *)databasePath;
-(KeepServer*) serverForName:(NSString *)serverName;
-(void) addServer:(ODKServer*) server atIndex:(NSInteger)index success:(void (^)(void)) success failure:(void (^)(void)) failure;

@end
