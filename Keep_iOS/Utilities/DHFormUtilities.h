//
//  DHFormUtilities.h
//  Keep
//
//  Created by Sean Patno on 10/25/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeepForm.h"
#import "KeepServer.h"

@interface DHFormUtilities : NSObject

+(NSArray*) flatQuestionList:(NSArray*) questionList;
+(BOOL) isReadOnly:(NSDictionary*) question;

+(BOOL) isQuestionRelevant:(NSDictionary*)question forAnswers:(NSDictionary*)answers isGroup:(BOOL)isGroup;
+(BOOL) isQuestionRequired:(NSDictionary*)question;
+(BOOL) doesQuestionPassConstraint:(NSDictionary*)question forAnswers:(NSDictionary*)answers;


+(NSString*) buildXMLFromAnswers:(NSDictionary*) answers;

+(NSString*) constructXMLFromQuestions:(NSArray*)questions forAnswers:(NSDictionary*) answers;

+(void) submitData:(NSDictionary*) xformData to:(NSString*)submissionURL success:(void (^)())success failure:(void (^)()) failure useProgress:(BOOL) useProgress;
+(void) submitForm:(KeepForm*) xform withData:(NSDictionary*) xformData completion:( void (^)() ) completion failure:(void (^)()) failure useProgress:(BOOL) useProgress;

+(void) sendStoredForms:(KeepServer*)server;

+(NSString *) performXPath:(NSString*)xquery onAnswers:(NSDictionary*)answers;
+(BOOL) evalXPath:(NSString*)eval onAnswers:(NSDictionary*)answers;

@end
