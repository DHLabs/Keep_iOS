//
//  XFormJSONConverter.m
//  Keep
//
//  Created by Sean Patno on 2/11/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "XFormJSONConverter.h"

#import "XMLReader.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"

#define kHTMLKey @"h:html"
#define kHeadKey @"h:head"
#define kTitleKey @"h:title"
#define kBodyKey @"h:body"

#define kBindKey @"bind"
#define kModelKey @"model"
#define kInstanceKey @"instance"

@interface XFormJSONConverter () 
@end

@implementation XFormJSONConverter

+(id) JSONFormFromXMLPath:(NSString *)path
{
    NSString* xmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    return [XFormJSONConverter JSONFormFromXMLString:xmlString];
}

+(id) JSONFormFromXMLString:(NSString *)xml
{
    NSError * error;

    NSMutableDictionary * jsonForm = [[NSMutableDictionary alloc] init];
    NSMutableArray * children = [[NSMutableArray alloc] init];
    NSMutableDictionary * choices = [[NSMutableDictionary alloc] init];

    CXMLDocument * xmlDocument = [[CXMLDocument alloc] initWithXMLString:xml options:CXMLDocumentTidyHTML error:&error];

    if( error ) {
        [jsonForm setValue:@"" forKey:@"children"];
        NSLog(@"unable to parse xml");
        return jsonForm;
    }

    NSString * realString = [NSString stringWithFormat:@"<xform>%@%@</xform>",[[[xmlDocument childAtIndex:0] childAtIndex:1] XMLString],[[[xmlDocument childAtIndex:0] childAtIndex:3] XMLString]];

    realString = [realString stringByReplacingOccurrencesOfString:@"<h:" withString:@"<"];
    realString = [realString stringByReplacingOccurrencesOfString:@"</h:" withString:@"</"];
    realString = [realString stringByReplacingOccurrencesOfString:@"jr:" withString:@""];

    CXMLDocument * fullDoc = [[CXMLDocument alloc] initWithXMLString:realString options:0 error:nil];

    NSError * nameError;
    NSArray* nodes = [fullDoc nodesForXPath:@"//head/title" error:&nameError];

    [jsonForm setValue:[[nodes objectAtIndex:0] stringValue] forKey:@"name"];

    NSArray * instance = [fullDoc nodesForXPath:@"//instance" error:nil];

    for( CXMLElement *node in instance ) {

        CXMLNode * idNode = [node attributeForName:@"id"];

        if( idNode ) {
            //this is a list of choices to parse
            NSMutableArray * array = [[NSMutableArray alloc] init];
            [XFormJSONConverter parseChoiceInstance:node into:array fromDoc:fullDoc];
            [choices setValue:array forKey:[idNode stringValue]];
        } else {
            //this is the real instance
            for( CXMLElement * child in [node childAtIndex:1].children) {
                if( [child.name isEqualToString:@"text"] ) {
                    continue;
                }

                NSString * questionPath = [NSString stringWithFormat:@"/%@", [node childAtIndex:1].name];
                [XFormJSONConverter parseElement:child into:children fromDoc:fullDoc path:questionPath];
            }
        }
    }

    [jsonForm setValue:children forKey:@"children"];
    
    return jsonForm;
}

+(void) parseChoiceInstance:(CXMLElement*) instance into:(NSMutableArray*)array fromDoc:(CXMLDocument*) document
{
    //TODO:

    //get the root element

    //iterate through item elements
}

+(void) parseElement:(CXMLElement *)element into:(NSMutableArray*) array fromDoc:(CXMLDocument*) document path:(NSString*) questionPath
{
    NSMutableDictionary * questionDict = [[NSMutableDictionary alloc] init];

    //handle standard question stuff
    [XFormJSONConverter parseQuestion:element into:questionDict fromDoc:document withPath:questionPath];

    if( [[questionDict valueForKey:@"type"] isEqualToString:@"group"] ) {
        //handle group
        NSMutableArray * groupChildren = [[NSMutableArray alloc] init];
        for( CXMLElement * child in [element children] ) {
            if( [child.name isEqualToString:@"text"] ) {
                //NSLog(@"text");
                continue;
            }

            NSString * newPath = [questionPath stringByAppendingFormat:@"/%@", element.name];
            [XFormJSONConverter parseElement:child into:groupChildren fromDoc:document path:newPath];
        }
        
        [questionDict setValue:groupChildren forKey:@"children"];
    }

    [array addObject:questionDict];
}

+(void) parseQuestion:(CXMLElement*) element into:(NSMutableDictionary*)questionDict fromDoc:(CXMLDocument*) document withPath:(NSString*) path
{
    NSString * questionPath = [path stringByAppendingFormat:@"/%@", element.name];
    //NSLog(@"question path: %@", questionPath);

    [questionDict setValue:questionPath forKey:@"path"];

    NSArray * mainArray = [document nodesForXPath:[NSString stringWithFormat:@"//*[@ref='%@']", questionPath] error:nil];
    CXMLElement * questionMain;
    if( [mainArray count] > 0 ) {

        questionMain = [mainArray objectAtIndex:0];

        NSMutableDictionary * controlDict = [[NSMutableDictionary alloc] init];
        //appearance
        CXMLNode * appearance = [questionMain attributeForName:@"appearance"];
        if( appearance ) {
            [controlDict setValue:[appearance stringValue] forKey:@"appearance"];
        }
        [questionDict setValue:controlDict forKey:@"control"];

        //label
        [XFormJSONConverter addLabelFrom:questionMain to:questionDict];

        //hint
        NSArray * hints = [questionMain elementsForName:@"hint"];
        if( hints && [hints count] > 0 ) {
            //TODO: hints
        }

        //items (choices)
        NSArray * items = [questionMain elementsForName:@"item"];
        if( items && [items count] > 0 ) {
            NSMutableArray * choices = [[NSMutableArray alloc] init];
            for( CXMLElement * item in items ) {
                NSMutableDictionary * itemDict = [[NSMutableDictionary alloc] init];
                [itemDict setValue:[[[item elementsForName:@"value"] objectAtIndex:0] stringValue] forKey:@"name"];
                [XFormJSONConverter addLabelFrom:item to:itemDict];
                [choices addObject:itemDict];
            }
            
            [questionDict setValue:choices forKey:@"choices"];
        }
    }

    //name
    [questionDict setValue:element.name forKey:@"name"];

    //default
    NSString * defaultValue = [element stringValue];
    if( defaultValue && ![defaultValue isEqualToString:@""] ) {
        [questionDict setValue:defaultValue forKey:@"default"];
    }

    //TODO: choice_filter and itemset
    
    //bind element
    NSArray * bindArray = [document nodesForXPath:[NSString stringWithFormat:@"//bind[@nodeset='%@']", questionPath] error:nil];
    if( [bindArray count] > 0 ) {
        NSMutableDictionary * bindDictionary = [[NSMutableDictionary alloc] init];
        
        CXMLElement * bind = [bindArray objectAtIndex:0];

        //constraint
        CXMLNode * constraintNode = [bind attributeForName:@"constraint"];
        if( constraintNode ) {
            [bindDictionary setValue:[constraintNode stringValue] forKey:@"constraint"];
        }

        //constraint message
        CXMLNode * contraintMsgNode = [bind attributeForName:@"constraint"];
        if( contraintMsgNode ) {
            [bindDictionary setValue:[constraintNode stringValue] forKey:@"constraint"];
        }

        //TODO: refactor types

        //question type
        CXMLNode * typeNode = [bind attributeForName:@"type"];
        if( typeNode ) {
            NSString * questionType = [typeNode stringValue];
            if( [questionType isEqualToString:@"binary"] ) {

                NSString * mediaType = [[questionMain attributeForName:@"mediatype"] stringValue];
                if( [mediaType isEqualToString:@"audio/*"] ) {
                    [questionDict setValue:@"audio" forKey:@"type"];
                } else if( [mediaType isEqualToString:@"image/*"] ) {
                    [questionDict setValue:@"photo" forKey:@"type"];
                } else if( [mediaType isEqualToString:@"video/*"] ) {
                    [questionDict setValue:@"video" forKey:@"type"];
                } else {
                    NSLog(@"ERROR: unexpected mediatype found");
                    [questionDict setValue:questionType forKey:@"type"];
                }

            } else {
                [questionDict setValue:questionType forKey:@"type"];
            }
        } else {
            if( [questionMain.name isEqualToString:@"group"] ) {
                [questionDict setValue:@"group" forKey:@"type"];
            } else if( [questionMain.name isEqualToString:@"trigger"] ) {
                [questionDict setValue:@"trigger" forKey:@"type"];
            } else {
                //TODO:?
                NSLog(@"no type: %@", questionMain.name);
            }
        }

        //relevant
        CXMLNode * relevantNode = [bind attributeForName:@"relevant"];
        if( relevantNode ) {
            [bindDictionary setValue:[relevantNode stringValue] forKey:@"relevant"];
        }

        //required
        CXMLNode * requiredNode = [bind attributeForName:@"required"];
        if( requiredNode ) {
            [bindDictionary setValue:[XFormJSONConverter getBooleanNodeAsString:[requiredNode stringValue]]  forKey:@"required"];
        }

        //readonly
        CXMLNode * readonlyNode = [bind attributeForName:@"readonly"];
        if( readonlyNode ) {
            [bindDictionary setValue:[XFormJSONConverter getBooleanNodeAsString:[readonlyNode stringValue]] forKey:@"readonly"];
        }
        
        //calculate
        CXMLNode * calculateNode = [bind attributeForName:@"calculate"];
        if( calculateNode ) {
            [bindDictionary setValue:[calculateNode stringValue] forKey:@"calculate"];
        }

        [questionDict setValue:bindDictionary forKey:@"bind"];
    } else {
        [questionDict setValue:@"group" forKey:@"type"];
    }

    if( !questionMain && [bindArray count] == 0 ) {
        return;
    }

    if( [[questionDict objectForKey:@"type"] isEqualToString:@"group"] ) {
        [questionDict removeObjectForKey:@"default"];
    }
                          
}

+(NSString*) getBooleanNodeAsString:(NSString*) nodeValue
{
    if( [nodeValue rangeOfString:@"true" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
        return @"yes";
    } else if( [nodeValue rangeOfString:@"false" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
        return @"no";
    } else if( [nodeValue rangeOfString:@"yes" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
        return @"yes";
    } else if( [nodeValue rangeOfString:@"no" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
        return @"no";
    }
    NSLog(@"somehting weird came across: %@", nodeValue);
    return @"no";
}

+(void) addLabelFrom:(CXMLElement*)element to:(NSDictionary*)questionDict
{
    //media
    NSMutableDictionary * mediaDictionary = [[NSMutableDictionary alloc] init];
   
    //label
    NSArray * labels = [element elementsForName:@"label"];
    if( [labels count] > 0 ) {
        for( CXMLElement * label in labels ) {
            CXMLNode * itext = [label attributeForName:@"ref"];
            if( itext ) {

                NSMutableDictionary * langDict = [[NSMutableDictionary alloc] init];
                NSString * xpath = [NSString stringWithFormat:@"//text[@id=\"%@\"]", [itext stringValue]];
                NSArray * languages = [[element rootDocument] nodesForXPath:xpath error:nil];
                for( CXMLElement * language in languages ) {
                    
                    NSString * languageName = [[(CXMLElement*)[language parent] attributeForName:@"lang"] stringValue];//TODO: might need some checks
                    for( CXMLElement * value in [language elementsForName:@"value"] ) {
                        CXMLNode * formNode = [value attributeForName:@"form"];
                        if( formNode ) {//media
                            NSString * mediaType = [formNode stringValue];
                            NSString * mediaFile = [[[value stringValue] componentsSeparatedByString:@"/"] lastObject];
                            [mediaDictionary setValue:mediaFile forKey:mediaType];
                        } else {//label
                            NSMutableString * string = [[NSMutableString alloc] init];
                            for( CXMLNode * node in value.children ) {
                                if( [node isKindOfClass:[CXMLElement class]] ) {
                                    NSString * valueString = [[(CXMLElement*)node attributeForName:@"value"] stringValue];
                                    valueString = [[valueString componentsSeparatedByString:@"/"] lastObject];
                                    [string appendString:[NSString stringWithFormat:@"${%@}", valueString]];
                                } else {
                                    [string appendString:[node stringValue]];
                                }
                            }
                            [langDict setValue:string forKey:languageName];
                        }
                    }
                }

                if( [[langDict allKeys] count] == 1 ) {
                    [questionDict setValue:[[langDict allValues] objectAtIndex:0] forKey:@"label"];
                } else {
                    [questionDict setValue:langDict forKey:@"label"];
                }

            } else {
                NSMutableString * string = [[NSMutableString alloc] init];
                for( CXMLNode * node in label.children ) {
                    if( [node isKindOfClass:[CXMLElement class]] ) {
                        NSString * valueString = [[(CXMLElement*)node attributeForName:@"value"] stringValue];
                        valueString = [[valueString componentsSeparatedByString:@"/"] lastObject];
                        [string appendString:[NSString stringWithFormat:@"${%@}", valueString]];
                    } else {
                        [string appendString:[node stringValue]];
                    }
                }
                [questionDict setValue:string forKey:@"label"];
            }
        }
    }

    if( [[mediaDictionary allKeys] count] > 0 ) {
        [questionDict setValue:mediaDictionary forKey:@"media"];
    }

}

@end
