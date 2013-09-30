//
//  DHCalcUtilities.h
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHCalcUtilities : NSObject

//Preprocessing steps, replacing and evaluating simple expressions
+(NSString*) replacePathsInExpression:(NSString *)expression withAnswers:(NSDictionary *)answers currentPath:(NSString*) currentPath;
+(NSString*) replaceFunctionsInExpression:(NSString *)expression withAnswers:(NSDictionary*)answers currentPath:(NSString*)currentPath;

+(BOOL) evaluateExpression:(NSString*)expression withAnswers:(NSDictionary*)answers andCurrentPath:(NSString*)currentPath;
+(NSString*) processExpression:(NSString*)expression withAnswers:(NSDictionary*)answers andCurrentPath:(NSString*)currentPath;

+(BOOL) passesTest:(NSString*)expression withAnswers:(NSDictionary*) answers andCurrentPath:(NSString*)currentPath;

+(NSString*) evaluateIfInExpression:(NSString*) expression withAnswers:(NSDictionary*) answers currentPath:(NSString*) currentPath;

+(NSInteger) findMatchingCharacter:(NSString *)character fromStart:(NSInteger)location inExpression:(NSString*) expression;

+(NSString*) evaluateMathExpression:(NSString *)expression withAnswers:(NSDictionary *)answers currentPath:(NSString*)currentPath;
+(NSString*) evaluateDateExpression:(NSString*)expression withAnswers:(NSDictionary*)answers currentPath:(NSString*)currentPath;

@end
