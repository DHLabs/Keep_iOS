//
//  DHCalcUtilities.m
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHCalcUtilities.h"

@implementation DHCalcUtilities

+(NSString*) replacePathsInExpression:(NSString *)expression withAnswers:(NSDictionary *)answers currentPath:(NSString*) currentPath
{

    NSRange pathStart = [expression rangeOfString:@"/"];
    NSString * slimmedExpression = [NSString stringWithString:expression];

    while (pathStart.location != NSNotFound) {

        //find end of path
        slimmedExpression = [slimmedExpression substringFromIndex:pathStart.location];

        NSRange ranges[5];
        ranges[0] = [slimmedExpression rangeOfString:@" "];
        ranges[1] = [slimmedExpression rangeOfString:@")"];
        ranges[2] = [slimmedExpression rangeOfString:@"*"];
        ranges[3] = [slimmedExpression rangeOfString:@"-"];
        ranges[4] = [slimmedExpression rangeOfString:@"="];
        //ranges[0] = [slimmedExpression rangeOfString:@"-"];

        NSInteger nearestLocation = ranges[0].location;
        for( int i=1; i<5; i++ ) {
            if( ranges[i].location < nearestLocation ) {
                nearestLocation = ranges[i].location;
            }
        }

        NSString * answerPath = [slimmedExpression substringToIndex:nearestLocation];

        NSLog(@"answerpath: %@", answerPath);

        id answer = [answers objectForKey:answerPath];
         NSString * answerString;

        if( [answer isKindOfClass:[NSDate class]] ) {
            //date in days
        } else if( [answer isKindOfClass:[NSString class]] ) {
            answerString = answer;
        } else if( [answer isKindOfClass:[NSNumber class]] ) {
            answerString = [NSString stringWithFormat:@"%f", [answer floatValue]];
        } else {
            NSLog(@"don't know, answer class: %@", [answer class]);
        }

        expression = [expression stringByReplacingCharactersInRange:NSMakeRange(pathStart.location, nearestLocation - pathStart.location) withString:answerString];

        pathStart = [expression rangeOfString:@"/"];
    }

    id currentAnswer = [answers objectForKey:currentPath];
    NSString * answerString;
    if( [currentAnswer isKindOfClass:[NSDate class]] ) {
        //date in days
    } else if( [currentAnswer isKindOfClass:[NSString class]] ) {
        answerString = currentAnswer;
    } else if( [currentAnswer isKindOfClass:[NSNumber class]] ) {
        answerString = [NSString stringWithFormat:@"%f", [currentAnswer floatValue]];
    } else {
        NSLog(@"don't know, answer class: %@", [answerString class]);
    }

    BOOL keepGoing = YES;
    NSRange stringRange = NSMakeRange(0, 1);

    while( keepGoing ) {
        for( int index=0; index<[expression length]; index++ ) {

            if( index == ([expression length] - 1) ) {
                keepGoing = NO;
            }

            stringRange.location = index;
            NSString * character = [expression substringWithRange:stringRange];
            if( [character isEqualToString:@"."] ) {
                //check if number
                //only replace .'s when it's not a number
                BOOL isNumber = NO;
                if( index != 0 ) {
                    NSString * numberString = [expression substringWithRange:NSMakeRange(index-1, 1)];
                    if( [[[NSNumberFormatter alloc] init] numberFromString:numberString] ) {
                        if( index != ( [expression length] - 1 ) ) {
                            numberString = [expression substringWithRange:NSMakeRange(index+1, 1)];
                            if( [[[NSNumberFormatter alloc] init] numberFromString:numberString] ) {
                                isNumber = YES;
                            }
                        }
                    }
                }

                if( !isNumber ) {
                    expression = [expression stringByReplacingCharactersInRange:[expression rangeOfString:@"."] withString:answerString];
                    break;
                }
            }
        }
    }

    return expression;
}

+(NSInteger) findMatchingCharacter:(NSString *)character fromStart:(NSInteger)location inExpression:(NSString*) expression
{
    NSRange range = NSMakeRange(1, 1);
    int openParens = 0;

    for( int index = (location+1); index < [expression length]; index++ ) {

        range.location = index;
        NSString * newCharacter = [expression substringWithRange:range];
        if( openParens == 0 && [newCharacter isEqualToString:character] ) {
            return index;
        }

        if( [newCharacter isEqualToString:@"("] ) {
            openParens++;
        } else if( [newCharacter isEqualToString:@")"] ) {
            openParens--;
        }
    }

    return -1;
}

+(NSString*) evaluateIfInExpression:(NSString*) expression withAnswers:(NSDictionary*) answers currentPath:(NSString*) currentPath
{
    int firstCommaLocation = [DHCalcUtilities findMatchingCharacter:@"," fromStart:-1 inExpression:expression];
    int secondCommaLocation = [DHCalcUtilities findMatchingCharacter:@"," fromStart:firstCommaLocation inExpression:expression];

    NSString * booleanExpression = [expression substringToIndex:firstCommaLocation];
    NSString * trueExpression = [[expression substringFromIndex:firstCommaLocation + 1] substringToIndex:secondCommaLocation];
    NSString * falseExpression = [expression substringFromIndex:secondCommaLocation+1];

    if( [DHCalcUtilities evaluateExpression:booleanExpression withAnswers:answers andCurrentPath:currentPath] ) {
        return [DHCalcUtilities processExpression:trueExpression withAnswers:answers andCurrentPath:currentPath];
    } else {
        return [DHCalcUtilities processExpression:falseExpression withAnswers:answers andCurrentPath:currentPath];
    }
}

+(NSString*) evaluateMathExpression:(NSString *)expression withAnswers:(NSDictionary *)answers currentPath:(NSString *)currentPath
{
    //TODO: finish this
    return @"";
}

+(NSString*) evaluateDateExpression:(NSString *)expression withAnswers:(NSDictionary *)answers currentPath:(NSString *)currentPath
{
    NSString * subExpression;
    return nil;
}

//+(NSString*) processDateExpression:(NSString *)expression w
//{
//    return nil;
//}

+(NSString*) processExpression:(NSString*)expression withAnswers:(NSDictionary*)answers andCurrentPath:(NSString*)currentPath
{
    //TODO: finish this

    int numTests = 13;
    NSRange range[numTests];
    int minIndex = -1;
    NSRange minRange;

    range[0] = [expression rangeOfString:@"("];
    range[1] = [expression rangeOfString:@" and "];
    range[2] = [expression rangeOfString:@" or "];
    range[3] = [expression rangeOfString:@"not("];
    range[4] = [expression rangeOfString:@"if("];
    range[5] = [expression rangeOfString:@"date("];
    range[6] = [expression rangeOfString:@"concat("];
    range[7] = [expression rangeOfString:@">="];
    range[8] = [expression rangeOfString:@">"];
    range[9] = [expression rangeOfString:@"<="];
    range[10] = [expression rangeOfString:@"<"];
    range[11] = [expression rangeOfString:@"="];
    range[12] = [expression rangeOfString:@"!="];

    //check if parentheses next to each other, don't need to evaluate expression if so
    if( [expression rangeOfString:@")"].location - range[0].location == 1) {
        range[0].location = NSNotFound;
    }

    //get first range that is there
    for( int i=0; i<numTests; i++ ) {
        if( range[i].location != NSNotFound ) {
            minIndex = i;
            minRange = range[i];
        }
    }
/*
    if( minIndex != -1 ) {
        for( int index = 1; index<numTests; index++) {
            if( range[index].location != NSNotFound && ( range[index].location < minRange.location ) ) {
                minRange = range[index];
                minIndex = index;
            }
        }

        if( minIndex == 0 ) {

            NSRange closeRange = [expression rangeOfString:@")" options:NSBackwardsSearch];

            NSString * parenString = [expression substringWithRange:NSMakeRange(minRange.location + 1, (closeRange.location - range.location - 2))];

            if( closeRange.location < ( [expression length] - 1 ) ) {

                NSString * leftOverString = [expression substringFromIndex:(closeRange.location + 1)];

                NSRange or = [leftOverString rangeOfString:@" or "];
                NSRange and = [leftOverString rangeOfString:@" and "];

                if( or.location != 0 ) {
                    return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath] || [DHCalcUtilities evaluateExpression:leftOverString withAnswers:answers andCurrentPath:currentPath];
                } else if( and.location != 0 ) {
                    return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath] && [DHCalcUtilities evaluateExpression:leftOverString withAnswers:answers andCurrentPath:currentPath];
                } else if( and.location != NSNotFound || or.location != NSNotFound ) {
                    NSLog(@"no or/and found where one should exist: %@. returning just the paren string evaluation", leftOverString);
                    return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath];
                }
            } else {
                return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath];
            }

        } else if( range.location == andRange.location ) {

            NSString * leftExpression = [expression substringToIndex:range.location];
            NSString * rightExpression =  [expression substringFromIndex:(range.location + range.length)];

            return [DHCalcUtilities evaluateExpression:leftExpression withAnswers:answers andCurrentPath:currentPath] && [DHCalcUtilities evaluateExpression:rightExpression withAnswers:answers andCurrentPath:currentPath];

        } else if( range.location == orRange.location ) {

            NSString * leftExpression = [expression substringToIndex:range.location];
            NSString * rightExpression =  [expression substringFromIndex:(range.location + range.length)];

            return [DHCalcUtilities evaluateExpression:leftExpression withAnswers:answers andCurrentPath:currentPath] || [DHCalcUtilities evaluateExpression:rightExpression withAnswers:answers andCurrentPath:currentPath];

        } else if( range.location == notRange.location ) {

            NSRange closeRange = [expression rangeOfString:@")" options:NSBackwardsSearch];
            NSRange newRange = NSMakeRange(range.location + range.length, ( closeRange.location - (range.location + range.length) ) );

            NSString * newExpression = [expression substringWithRange:newRange];
            
            return ( ! [DHCalcUtilities evaluateExpression:newExpression withAnswers:answers andCurrentPath:currentPath] );
        }
    } else {
        //TODO: fix this
        return [DHCalcUtilities passesTest:expression withAnswers:answers andCurrentPath:currentPath];
    }*/

    return @"''";
}

//function recursively breaks down logical expression for individual evaluation and then reconstruction back up the tree
+(BOOL)evaluateExpression:(NSString *)expression withAnswers:(NSDictionary *)answers andCurrentPath:(NSString*)currentPath
{
    //evaluate all selected
    NSRange range;

    NSRange scopeRange = [expression rangeOfString:@"("];
    NSRange andRange = [expression rangeOfString:@" and "];
    NSRange orRange = [expression rangeOfString:@" or "];
    NSRange notRange = [expression rangeOfString:@"not("];
    NSRange ifRange = [expression rangeOfString:@"if("];
    NSRange dateRange = [expression rangeOfString:@"date("];
    NSRange concatRange = [expression rangeOfString:@"concat("];

    range = scopeRange;
    BOOL scope = YES;

    if( (andRange.location != NSNotFound) && andRange.location < range.location ) {
        range = andRange;
        scope = NO;
    }

    if( (orRange.location != NSNotFound) && orRange.location < range.location ) {
        range = orRange;
        scope = NO;
    }

    if( (notRange.location != NSNotFound) && notRange.location < range.location ) {
        range = notRange;
        scope = NO;
    }

    if( scope ) {
        if( [expression rangeOfString:@")"].location - scopeRange.location == 1 ) {
            range.location = NSNotFound;
        }
    }

    if(range.location != NSNotFound) {

        if( range.location == scopeRange.location ) {

            NSRange closeRange = [expression rangeOfString:@")" options:NSBackwardsSearch];

            NSString * parenString = [expression substringWithRange:NSMakeRange(range.location + 1, (closeRange.location - range.location - 2))];

            if( closeRange.location < ( [expression length] - 1 ) ) {

                NSString * leftOverString = [expression substringFromIndex:(closeRange.location + 1)];

                NSRange or = [leftOverString rangeOfString:@" or "];
                NSRange and = [leftOverString rangeOfString:@" and "];

                if( or.location != 0 ) {
                    return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath] || [DHCalcUtilities evaluateExpression:leftOverString withAnswers:answers andCurrentPath:currentPath];
                } else if( and.location != 0 ) {
                    return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath] && [DHCalcUtilities evaluateExpression:leftOverString withAnswers:answers andCurrentPath:currentPath];
                } else if( and.location != NSNotFound || or.location != NSNotFound ) {
                    NSLog(@"no or/and found where one should exist: %@. returning just the paren string evaluation", leftOverString);
                    return YES;
                    //return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath];
                }
            } else {
                return [DHCalcUtilities evaluateExpression:parenString withAnswers:answers andCurrentPath:currentPath];
            }

        } else if( range.location == andRange.location ) {

            NSString * leftExpression = [expression substringToIndex:range.location];
            NSString * rightExpression =  [expression substringFromIndex:(range.location + range.length)];

            return [DHCalcUtilities evaluateExpression:leftExpression withAnswers:answers andCurrentPath:currentPath] && [DHCalcUtilities evaluateExpression:rightExpression withAnswers:answers andCurrentPath:currentPath];

        } else if( range.location == orRange.location ) {

            NSString * leftExpression = [expression substringToIndex:range.location];
            NSString * rightExpression =  [expression substringFromIndex:(range.location + range.length)];

            return [DHCalcUtilities evaluateExpression:leftExpression withAnswers:answers andCurrentPath:currentPath] || [DHCalcUtilities evaluateExpression:rightExpression withAnswers:answers andCurrentPath:currentPath];

        } else if( range.location == notRange.location ) {

            NSRange closeRange = [expression rangeOfString:@")" options:NSBackwardsSearch];
            NSRange newRange = NSMakeRange(range.location + range.length, ( closeRange.location - (range.location + range.length) ) );

            NSString * newExpression = [expression substringWithRange:newRange];

            return ( ! [DHCalcUtilities evaluateExpression:newExpression withAnswers:answers andCurrentPath:currentPath] );
        }

    } else {
        return [DHCalcUtilities passesTest:expression withAnswers:answers andCurrentPath:currentPath];
    }

    NSLog(@"Should never be here");

    return YES;
}

//this function evaluates the base logical expression, i.e. ( x != y ), no and's, or's, or not's anymore at this level
+(BOOL) passesTest:(NSString *)expression withAnswers:(NSDictionary *)answers andCurrentPath:(NSString*)currentPath
{

    //evaluate the equality
    if( [expression isEqualToString:@"YES"] ) {
        return YES;
    } else if( [expression isEqualToString:@"NO"] ) {
        return NO;
    }

    NSString * compareString = nil;

    if( [expression rangeOfString:@"<="].location != NSNotFound ) {
        compareString = @"<=";
    } else if( [expression rangeOfString:@">="].location != NSNotFound ) {
        compareString = @">=";
    } else if( [expression rangeOfString:@"!="].location != NSNotFound ) {
        compareString = @"!=";
    } else if( [expression rangeOfString:@"="].location != NSNotFound ) {
        compareString = @"=";
    } else if( [expression rangeOfString:@"<"].location != NSNotFound ) {
        compareString = @"<";
    } else if( [expression rangeOfString:@">"].location != NSNotFound ) {
        compareString = @">";
    } else {
        NSLog(@"Pass Test failure. No comparison string found. Should not happen");

        return YES;
    }

    NSArray * comps = [expression componentsSeparatedByString:compareString];

    NSString * leftString = [[comps objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if( [leftString isEqualToString:@"."] ) {
        leftString = currentPath;
    }

    NSString * rightString = [[comps objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString * leftAnswer = nil;
    NSString * rightAnswer = nil;

    //check if leftstring is a path to question
    if( [leftString rangeOfString:@"/"].location != NSNotFound ) {
        leftAnswer = [answers objectForKey:leftString];

        if( [leftAnswer isKindOfClass:[NSArray class]] ) {
            leftAnswer = @"''";
        }
    } else {
        NSLog(@"Left String is not a path. Returning NO");
        return NO;
    }

    if( [rightString rangeOfString:@"/"].location != NSNotFound ) {
        rightAnswer = [answers objectForKey:rightString];

        if( [rightAnswer isKindOfClass:[NSArray class]] ) {
            rightAnswer = @"''";
        }
    } else {
        rightAnswer = rightString;
    }

    //nil cases
    if( !leftAnswer || !rightAnswer ) {
        if( leftAnswer ) {
            if( [compareString isEqualToString:@"!="] ) {
                return YES;
            }
        } else if(rightAnswer) {
            if( [compareString isEqualToString:@"!="] && [rightAnswer isEqualToString:@"''"] ) {
                return NO;
            } else if( [compareString isEqualToString:@"="] && [rightAnswer isEqualToString:@"''"] ) {
                return YES;
            } else if([compareString isEqualToString:@"!="]) {
                return YES;
            }
        } else {
            if( [compareString isEqualToString:@"="] ) {
                return YES;
            }
        }

        return NO;
    }

    //evaluate the expression

    //special function cases
    if( [rightAnswer isEqualToString:@"today()"] ) {

        //date comparison
        NSCalendar* calendar = [NSCalendar currentCalendar];

        NSDateFormatter * format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";
        NSDate * date = [format dateFromString:leftAnswer];
        
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        NSDateComponents* compare = [calendar components:unitFlags fromDate:date];
        NSDateComponents* currentDate = [calendar components:unitFlags fromDate:[NSDate date]];

        NSLog(@"test1");
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:[NSDate date]];
        NSLog(@"tst2");

        if( [compareString isEqualToString:@"<="] ) {
            if( timeInterval < 0 ) {
                return YES;
            }
        } else if( [compareString isEqualToString:@">="] ) {
            if( timeInterval > 0 ) {
                return YES;
            }
        } else if( [compareString isEqualToString:@"="] ) {
            if( ( fabs(timeInterval) < 86400 ) && ( [compare day] == [currentDate day] )  ) {
                return YES;
            }
        } else if( [compareString isEqualToString:@"<"] ) {
            if( ( timeInterval < 0 ) && ( [compare day] != [currentDate day] )  ) {
                return YES;
            }
        } else if( [compareString isEqualToString:@">"] ) {
            if( ( timeInterval > 0 ) && ( [compare day] != [currentDate day] )  ) {
                return YES;
            }
        } else {
            if([compare day] != [currentDate day]) {
                return YES;
            }
        }

        return NO;

    } else {
        //check if number
        NSNumber * number = [[[NSNumberFormatter alloc] init] numberFromString:rightAnswer];

        if( number != nil ) {

            NSLog(@"is number");

            if( [compareString isEqualToString:@"<"] ) {
                return [leftAnswer floatValue] < [rightAnswer floatValue];
            } else if( [compareString isEqualToString:@">"] ) {
                return [leftAnswer floatValue] > [rightAnswer floatValue];
            } else if( [compareString isEqualToString:@"="] ) {
                return [leftAnswer floatValue] == [rightAnswer floatValue];
            } else if( [compareString isEqualToString:@"<="] ) {
                return [leftAnswer floatValue] <= [rightAnswer floatValue];
            } else if( [compareString isEqualToString:@">="] ) {
                return [leftAnswer floatValue] >= [rightAnswer floatValue];
            } else {
                return [leftAnswer floatValue] != [rightAnswer floatValue];
            }

        } else {

            NSLog(@"not number comparison");
            //if it's not a number, then it should be a selection choice (string)
            //string comparisons are only equal or not equal

            //remove quotes and whitespace

            rightAnswer = [rightAnswer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            rightAnswer = [rightAnswer stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            rightAnswer = [rightAnswer stringByReplacingOccurrencesOfString:@"'" withString:@""];

            NSLog(@"right string: %@", rightAnswer);

            //rightAnswer = [[[rightAnswer componentsSeparatedByString:@"'"] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if( [compareString isEqualToString:@"="] ) {
                return [leftAnswer isEqualToString:rightAnswer];
            } else if( [compareString isEqualToString:@"!="] ) {
                return (! [leftAnswer isEqualToString:rightAnswer] );
            } else {
                //shouldn't get here
                NSLog(@"string comparison not valid comparator. returning no");
                return YES;
            }
        }
    }
    
}

@end
