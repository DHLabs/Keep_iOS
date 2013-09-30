//
//  DataManager.m
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "DataManager.h"

#import "XMLReader.h"
#import "KeepForm.h"
#import "AFXMLRequestOperation.h"

@implementation DataManager

static DataManager* theManager;
@synthesize servers;
@synthesize storedForms;

+(DataManager*)instance
{
    if( theManager == nil )
    {
        theManager = [[DataManager alloc] init];
    }
    return theManager;
}

-(id) init
{
    self = [super init];
    if( self != nil ) {
        self.servers = [[NSMutableArray alloc] initWithCapacity:5];
        self.storedForms = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

-(void)saveDataToFilesystem
{
	NSDate *startTime = [NSDate date];
	BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:self.databasePath];
	if( success == NO )
	{
		NSLog(@"Failed to save the data.");
	}
	else
	{
		NSLog(@"Database saved.");
	}
	NSLog(@"Time to save database:%f seconds", -[startTime timeIntervalSinceNow] );
}

-(void) addServer:(ODKServer *)server atIndex:(NSInteger)index success:(void (^)(void))success failure:(void (^)(void))failure
{
    indexToAdd = index;

    newServer = server;
    addFailure = failure;
    addSuccess = success;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/formList", newServer.serverURL]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {

        xml = @"";
        XMLParser.delegate = self;
        [XMLParser parse];        

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {

        NSLog(@"failure: %@", error);
        //TODO: alert that something went wrong

        [addFailure invoke];
        
    }];
    
    [operation start];
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    xml = [xml stringByAppendingFormat:@"<%@>", elementName];
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    xml = [xml stringByAppendingFormat:@"</%@>", elementName];
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    xml = [xml stringByAppendingString:string];
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSError * error;

    //need to escape & characters for dictionary conversion
    xml = [xml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];

    NSDictionary * dict = [XMLReader dictionaryForXMLString:xml error:&error];

    if( error ) {

        [addFailure invoke];
        return;
    }

    newServer.forms = [[NSMutableArray alloc] init];

    NSDictionary * xformsDict = [dict objectForKey:@"xforms"];

    if( !xformsDict || [xformsDict isEqual:[NSNull null]] ) {
        //not a proper xforms server
        [addFailure invoke];

    } else {
        id xforms = [xformsDict objectForKey:@"xform"];

        if( [xforms isKindOfClass:[NSDictionary class]] ) {
            ODKForm * form = [[ODKForm alloc] init];
            form.description = [xforms objectForKey:@"descriptionText"];
            form.downloadURL = [xforms objectForKey:@"downloadUrl"];
            form.manifestURL = [xforms objectForKey:@"manifestUrl"];
            form.name = [xforms objectForKey:@"name"];
            form.formID = [xforms objectForKey:@"formID"];
            form.formType = [xforms objectForKey:@"type"];
            form.serverName = [NSString stringWithString:newServer.serverURL];

            [newServer.forms addObject:form];
        } else {
            for( NSDictionary * xform in xforms ) {

                //NSLog(@"formL %@", xform);

                ODKForm * form = [[ODKForm alloc] init];
                form.description = [xform objectForKey:@"descriptionText"];
                form.downloadURL = [xform objectForKey:@"downloadUrl"];
                form.manifestURL = [xform objectForKey:@"manifestUrl"];
                form.name = [xform objectForKey:@"name"];
                form.formID = [xform objectForKey:@"formID"];
                form.formType = [xform objectForKey:@"type"];
                form.serverName = [NSString stringWithString:newServer.serverURL];

                [newServer.forms addObject:form];
            }
        }

        if( indexToAdd > 0 && indexToAdd < [self.servers count] ) {
            [self.servers insertObject:newServer atIndex:indexToAdd];
        } else {
            [self.servers addObject:newServer];
        }
        
        [addSuccess invoke];
    }
}

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    return [documentsDirectory stringByAppendingPathComponent:@"ServerForms.db"];
}

-(void)loadDataFromFilesystem
{
	NSString *dbPath = [self databasePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
		//The file wasn't found.
    }
    else
    {
		NSDate *startTime = [NSDate date];

		DataManager *dataManager = [NSKeyedUnarchiver unarchiveObjectWithFile:dbPath];
		if( dataManager != nil )
		{
			self.servers = dataManager->servers;
            self.storedForms = dataManager->storedForms;
            if(self.servers == nil) {
                self.servers = [[NSMutableArray alloc] initWithCapacity:1];
            }

            if(self.storedForms == nil) {
                self.storedForms = [[NSMutableArray alloc] initWithCapacity:1];
            }
		}
		else
		{
			NSLog(@"failed to load data");
		}

		NSLog(@"Time to load database:%f seconds", -[startTime timeIntervalSinceNow] );
    }

}

-(KeepServer*) serverForName:(NSString *)serverName
{
    for( ODKServer * server in self.servers ) {
        if( [server.serverURL isEqualToString:serverName] ) {
            return server;
        }
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self.servers = [coder decodeObjectForKey:@"servers"];
    self.storedForms = [coder decodeObjectForKey:@"storedForms"];
   
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.servers forKey:@"servers"];
    [coder encodeObject:self.storedForms forKey:@"storedForm"];
}

@end
