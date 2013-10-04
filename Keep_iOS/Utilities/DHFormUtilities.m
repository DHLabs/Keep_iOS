//
//  DHFormUtilities.m
//  Keep
//
//  Created by Sean Patno on 10/25/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "DHFormUtilities.h"

#import "DataManager.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "StoredForm.h"
#import "DHCalcUtilities.h"
#import "XPathQuery.h"

@implementation DHFormUtilities

+(BOOL) doesQuestionPassConstraint:(NSDictionary *)question forAnswers:(NSDictionary *)answers
{
    BOOL passesConstraint = YES;

    if([[question allKeys] containsObject:@"constraint"])
    {
        passesConstraint = YES;

        NSString* constraint = [question objectForKey:@"constraint"];

        NSLog(@"Constraint: %@", constraint);

        NSString * expression = [DHFormUtilities evaluateSelectedInExpression:constraint withAnswers:answers andCurrentPath:[question objectForKey:@"path"]];
        @try {
            return [DHCalcUtilities evaluateExpression:expression withAnswers:answers andCurrentPath:[question objectForKey:@"path"]];
        }
        @catch (NSException *exception) {
            NSLog(@"exception occurred: %@", exception);
            return YES;
        }
    }
    return passesConstraint;
}

+(BOOL) isQuestionRelevant:(NSDictionary *)question forAnswers:(NSDictionary *)answers isGroup:(BOOL)isGroup
{
    BOOL containsRelevant = [[question allKeys] containsObject:@"relevant"];

    NSLog(@"i shouldn't be here");

    if( !isGroup && ![question objectForKey:@"type"] ) {
        return NO;
    }

    //question not relevant to show if metadata, will be handled on its own
    if( [[question allKeys] containsObject:@"metadata"] ) {
        return NO;
    }

    if ([[question objectForKey:@"type"] isEqualToString:@"calculate"]) {
        //TODO: perform the calculation
        NSString * calculate = [question objectForKey:@"calculate"];
        if( calculate ) {
        }
        return NO;
    }

    if( [question objectForKey:@"calculate"] ) {
        //[answers setValue:[[question objectForKey:@"calculate"] stringByReplacingOccurrencesOfString:@"'" withString:@""] forKey:[question objectForKey:@"path"]];
        //[answers setValue:@"test" forKey:[question objectForKey:@"path"]];
        return NO;
    }

    if (containsRelevant) {

        NSString* relevantString = [question objectForKey:@"relevant"];
        NSString * expression = [relevantString stringByReplacingOccurrencesOfString:@"." withString:[question objectForKey:@"path"]];

        expression = [DHFormUtilities evaluateSelectedInExpression:expression withAnswers:answers andCurrentPath:[question objectForKey:@"path"]];

        return [DHCalcUtilities evaluateExpression:expression withAnswers:answers andCurrentPath:[question objectForKey:@"path"]];
    } else {
        return YES;
    }
}

//function replaces all "selected(.,'foo')" with evaluated boolean of YES or NO
+(NSString*) evaluateSelectedInExpression:(NSString*) expression withAnswers:(NSDictionary*)answers andCurrentPath:(NSString*)currentPath
{
    BOOL keepGoing = YES;

    NSString * string = [NSString stringWithString:expression];

    while (keepGoing) {

        NSRange range = [string rangeOfString:@"selected("];

        if( range.location != NSNotFound ) {

            NSString * substring = [string substringFromIndex:( range.location + range.length )];
            NSRange endRange = [substring rangeOfString:@")"];
            NSString * selected = [substring substringToIndex:endRange.location+1];

            NSArray * components = [selected componentsSeparatedByString:@","];

            //check for answer
            NSString * leftString = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString * rightString = [[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if( [leftString isEqualToString:@"."] ) {
                leftString = currentPath;
            }

            //remove quotes from rightstring
            rightString = [rightString stringByReplacingOccurrencesOfString:@"'" withString:@""];
            rightString = [rightString stringByReplacingOccurrencesOfString:@")" withString:@""];

            NSString * answer = [answers objectForKey:leftString];
            NSArray * answerComponents = [answer componentsSeparatedByString:@" "];

            NSRange replaceRange = NSMakeRange(range.location, [string rangeOfString:@")" options:NSLiteralSearch range:NSMakeRange(range.location, string.length - range.location)].location + 1 - range.location );
            if( [answerComponents containsObject:rightString] ) {
                string = [string stringByReplacingCharactersInRange:replaceRange withString:@"YES"];
            } else {
                string = [string stringByReplacingCharactersInRange:replaceRange withString:@"NO"];
            }            

        } else {
            keepGoing = NO;
        }
    }

    return string;
}

+(NSString*) buildXMLFromAnswers:(NSDictionary *)answers
{
    NSMutableString * mutableString = [[NSMutableString alloc] init];

    for( NSString * questionName in [answers allKeys] ) {

        id value = [answers objectForKey:questionName];
        if( [value isKindOfClass:[NSArray class]] ) {
            //this takes care of repeated groups
            for( NSDictionary * repeatedGroup in value ) {
                [mutableString appendFormat:@"<%@>\n", questionName];
                [mutableString appendString:[DHFormUtilities buildXMLFromAnswers:repeatedGroup]];
                [mutableString appendFormat:@"</%@>\n", questionName];
            }
            
        } else {
            [mutableString appendFormat:@"<%@>\n", questionName];
            if( [value isKindOfClass:[NSURL class]] ) {
                [mutableString appendString:[[[value absoluteString] componentsSeparatedByString:@"/"] lastObject]];
            } else if( [value isKindOfClass:[NSDictionary class]] ) {
                [mutableString appendString:[DHFormUtilities buildXMLFromAnswers:value]];
            } else if( [value isKindOfClass:[NSString class]] ) {
                [mutableString appendString:value];
            } else {
                [mutableString appendString:[value description]];
            }
            
            [mutableString appendFormat:@"</%@>\n", questionName];
        }
    }

    return mutableString;
}

+(NSString*) constructXMLFromQuestions:(NSArray *)questions forAnswers:(NSDictionary *)answers
{
    NSMutableString * xmlString = [NSMutableString string];

    int questionIndex = 0;

    while( questionIndex < [questions count] ) {

        NSString * questionPath = [questions objectAtIndex:questionIndex];

        NSRange range = [questionPath rangeOfString:@"/"];

        if( range.location == NSNotFound ) {

            id answer = [answers objectForKey:questionPath];
            NSString * answerString;
            if( [answer isKindOfClass:[NSURL class]] ) {
                NSLog(@"answer is url: %@", answer);
                //answerString = [[answer absoluteString] substringFromIndex:[[answer absoluteString] rangeOfString:@"?"].location + 4];
                //answerString = [answerString substringToIndex:[answerString rangeOfString:@"&"].location];
                answerString = [[[answer absoluteString] componentsSeparatedByString:@"/"] lastObject];
                //answerString = [answerString stringByAppendingString:@".png"];
            } else if( [answer isKindOfClass:[NSString class]] ) {
                answerString = answer;
            } else {
                //NSLog(@"answer is not string or url, uh oh %@", answer);
                answerString = [answer description];
            }

            [xmlString appendFormat:@"<%@>%@</%@>\n", questionPath, answerString,questionPath];
            questionIndex++;
        } else {
            NSString * tag = [questionPath substringToIndex:range.location];

            NSMutableArray * newQuestions = [NSMutableArray array];
            NSMutableDictionary * newAnswers = [NSMutableDictionary dictionary];

            //open tag
            [xmlString appendFormat:@"<%@>\n", tag];

            while( questionIndex < [questions count] ) {

                questionPath = [questions objectAtIndex:questionIndex];
                NSRange tagRange = [questionPath rangeOfString:[NSString stringWithFormat:@"%@/",tag]];

                if( tagRange.location != NSNotFound ) {
                    NSString * newPath = [questionPath substringFromIndex:(tagRange.length)];

                    [newQuestions addObject:newPath];
                    [newAnswers setObject:[answers objectForKey:questionPath] forKey:newPath];
                } else {
                    break;
                }
                questionIndex++;
            }

            [xmlString appendString:[DHFormUtilities constructXMLFromQuestions:newQuestions forAnswers:newAnswers]];

            //close tag
            [xmlString appendFormat:@"</%@>\n", tag];
        }
    }

    return xmlString;
}

+(void) submitForm:(KeepForm*) xform withData:(NSDictionary*) xformData completion:(void (^)())completion failure:(void (^)())failure useProgress:(BOOL)useProgress
{
    NSString* uuidstring = [[NSUserDefaults standardUserDefaults] objectForKey:@"application_UUID"];

    NSString * submissionURL = [NSString stringWithFormat:@"%@/submission?iphone_id=%@", xform.serverName,uuidstring];

    if( useProgress ) {
        [SVProgressHUD showWithStatus:@"Submitting" maskType:SVProgressHUDMaskTypeGradient];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:submissionURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        NSString * xmlString = [DHFormUtilities buildXMLFromAnswers:xformData];

        [formData appendPartWithFileData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"xml_submission_file" fileName:@"xml_submission_file" mimeType:@"application/octet-stream"];

        NSString * filename;
        for( id answer in [xformData allValues] ) {
            if( [answer isKindOfClass:[NSURL class]] ) {

                filename = [[[answer absoluteString] componentsSeparatedByString:@"/"] lastObject];;

                NSString * fileExtension = [[filename componentsSeparatedByString:@"."] lastObject];
                NSString * mimeType = @"image/png";
                if( [fileExtension isEqualToString:@"mov"] ) {
                    mimeType = @"video/quicktime";
                }
                [formData appendPartWithFileURL:answer name:filename fileName:filename mimeType:mimeType error:nil];
                //[formData appendPartWithFileData:[NSData dataWithContentsOfURL:(NSURL*)answer] name:filename fileName:filename mimeType:mimeType];
            }
        }

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        [completion invoke];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [failure invoke];
    }];

}

+(void) sendStoredForms:(KeepServer*)server
{

    NSMutableArray * storedForms;// = [DataManager instance].storedForms;
    if( server ) {
        storedForms = server.storedForms;
    } else {
        //for( ODKServer * oserver in [DataManager instance].servers ) {
        //    [storedForms addObjectsFromArray:oserver.storedForms];
        //}

        storedForms = [[NSMutableArray alloc] init];
        [storedForms addObjectsFromArray:[DataManager instance].storedForms];
    }

    for( StoredForm * storedForm in storedForms ) {

        if( !storedForm.isFinished ) {
            continue;
        }

        /*DHxFormTool * tool = [[DHxFormTool alloc] init];
        NSString* filePath=[storedForm.xform.formPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", storedForm.xform.formID]];
        [tool loadWithPath:filePath];
        [tool parseBindOrder];
        [tool parseInstanceDictionary];
        [tool parseBody];

        [DHFormUtilities submitForm:storedForm.xform withData:storedForm.formData tool:tool completion:^(){
            //delete upon success
            //possible concurrency issue? modifying array while iterating through
            //[storedForms removeObject:storedForm];
            //deelete stored form
            if( server ) {
                [server.storedForms removeObject:storedForm];
            } else {
                [[DataManager instance].storedForms removeObject:storedForm];
            }

        } failure:^() {
            //keep form data if failed to upload again

            //therefore, do nothing
        } useProgress:NO];*/
    }
    
}

+(NSArray*) flatQuestionList:(NSArray*) questionList {

    NSMutableArray * flatList = [[NSMutableArray alloc] init];

    for( NSDictionary * question in questionList ) {

        [flatList addObject:question];
        if( [[question objectForKey:@"type"] isEqualToString:@"group"] ) {

            //TODO: only add objects from non field and grid list group
            [flatList addObjectsFromArray:[self flatQuestionList:[question objectForKey:@"children"]]];
        }
    }

    return flatList;
}

+(BOOL) isReadOnly:(NSDictionary *)question
{
    BOOL readOnly = NO;
    if([[question allKeys] containsObject:@"readonly"])
    {
        //readOnly = [self readOnlyFromString:[question objectForKey:@"readonly"]];
        readOnly = YES;
    }
    return NO;
}

+(NSString *) performXPath:(NSString*)xquery onAnswers:(NSDictionary*)answers
{
    NSString * xml = [DHFormUtilities buildXMLFromAnswers:answers];

    NSLog(@"query: %@", xquery);

    NSData * docData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * queryResult = EvaluateXPathCalculate(docData, xquery);
    
    return queryResult;
}

+(BOOL) evalXPath:(NSString*)eval onAnswers:(NSDictionary*)answers
{
    NSString * xml = [DHFormUtilities buildXMLFromAnswers:answers];

    NSLog(@"query: %@", eval);

    NSData * docData = [xml dataUsingEncoding:NSUTF8StringEncoding];

    return EvaluateXPathExpression(docData, eval);
}

+(BOOL) isQuestionRequired:(NSDictionary *)question
{
    //TODO: might need more here

    //just let triggers/acknowledges go through
    if( [[question objectForKey:@"type"] isEqualToString:@"trigger"] ) {
        return NO;
    }

    NSLog(@"required test");
    if ([[question allKeys] containsObject:@"required"]) {

        NSRange requiredRange = [[question objectForKey:@"required"] rangeOfString:@"true"];
        NSLog(@"test done");
        if (requiredRange.length != NSNotFound) {
            return YES;
        }
        return NO;
    }
    return NO;
}

@end
