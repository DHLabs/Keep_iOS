//
//  NewFormServerController.m
//  iODK
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "NewFormServerController.h"

#import "AFXMLRequestOperation.h"
#import "DataManager.h"
#import "XMLReader.h"
#import "ODKForm.h"
#import "SVProgressHUD.h"
#import "BlockAlertView.h"

#define defaultServer @"http://keep.distributedhealth.org/bs/sean"//@"http://formhub.org/spatno"
//@"http://odk.distributedhealth.org/bs/sean"

@implementation NewFormServerController

-(void) submitServer:(QElement*)element
{
    //Validate fields

    NSString * serverName = ((QEntryElement*)[self.root elementWithKey:@"serverName"]).textValue;
    if( (!serverName) || [serverName isEqualToString:@""] || [[serverName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ) {

        [NewFormServerController showMessageOnlyAlert:@"Please write in a server name"];
        return;

    }

    ODKServer *server = [[ODKServer alloc] init];

    QEntryElement * elem = (QEntryElement*)[self.root elementWithKey:@"serverURL"];
    
    NSString * serverURL = [NSString stringWithFormat:@"%@/formList", elem.textValue];
    NSString * otherServerURL;

    if( [elem.title isEqualToString:@"Keep Account"] ) {
        otherServerURL = [@"http://keep.distributedhealth.org/bs/" stringByAppendingString:elem.textValue];
        server.isKeep = YES;
        serverURL = [@"http://keep.distributedhealth.org/bs/" stringByAppendingString:serverURL];
    } else if( [elem.title isEqualToString:@"Formhub Account"] ) {
        otherServerURL = [@"https://formhub.org/" stringByAppendingString:elem.textValue];
        serverURL = [@"https://formhub.org/" stringByAppendingString:serverURL];
    } else {
        otherServerURL = elem.textValue;
    }

    for( ODKServer * theServer in [DataManager instance].servers  ) {
        if( [theServer.name isEqualToString:serverName] ) {
            [NewFormServerController showMessageOnlyAlert:@"That server name is already taken."];
            return;
        }

        if( [theServer.serverURL isEqualToString:otherServerURL] ) {
            [NewFormServerController showMessageOnlyAlert:@"That server URL is already is use."];
            return;
        }
    }

    NSLog(@"server url: %@", serverURL);

    if( ![NewFormServerController validateUrl:serverURL] ) {

        [NewFormServerController showMessageOnlyAlert:@"Please write in a valid server url"];        
        return;
    }
    
    server.serverURL = otherServerURL;
    server.name = serverName;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[DataManager instance] addServer:server atIndex:-1 success:^() {

        [self dismissModalViewControllerAnimated:YES];
        [SVProgressHUD dismiss];
    } failure:^() {

        [NewFormServerController showMessage:nil withTitle:@"That is not a valid form server"];
        [SVProgressHUD dismiss];
    }];
    
}

+(void) showMessageOnlyAlert:(NSString *) message
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:nil message:message];

    [alert setDestructiveButtonWithTitle:@"OK" block:nil];

    [alert show];
}

+(void) showMessage:(NSString*)message withTitle:(NSString*)title
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];

    [alert setDestructiveButtonWithTitle:@"OK" block:nil];

    [alert show];
}

+ (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

-(void) cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"New Server";
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];

    NSString * imageName = @"backgroundshort.png";
    if( [UIScreen mainScreen].bounds.size.height > 600 ) {
        NSLog(@"ipad");
        imageName = @"backgroundipad.png";
    } else if( [UIScreen mainScreen].bounds.size.height > 480 ) {
        NSLog(@"iphone 5");
        imageName = @"backgroundtall.png";
    } else {
        NSLog(@"iphone");
    }

    UIImage* image = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setFrame:self.quickDialogTableView.frame];

    self.quickDialogTableView.backgroundView = imageView;
    self.quickDialogTableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundiphone"]];
    
}

+(QRootElement*) getRootForType:(int)type
{
    QRootElement * elem = [[QRootElement alloc] init];
    elem.grouped = YES;
    elem.title = @"New Server";

    QSection * section = [[QSection alloc] init];

    QEntryElement * nameElement = [[QEntryElement alloc] initWithTitle:@"Name" Value:nil Placeholder:@"my server"];
    nameElement.key = @"serverName";
    [section addElement:nameElement];

    QEntryElement * serverURLElement;
    if( type == 1 ) {
        serverURLElement = [[QEntryElement alloc] initWithTitle:@"Keep Account" Value:@"mikepreziosi" Placeholder:@"account"];
        //serverURLElement.keyboardType = UIKeyboardTypeURL;
        
    } else if( type == 2 ) {
        serverURLElement = [[QEntryElement alloc] initWithTitle:@"Formhub Account" Value:@"formhub_u" Placeholder:@"account"];
        //serverURLElement.keyboardType = UIKeyboardTypeURL;
    } else {
        serverURLElement = [[QEntryElement alloc] initWithTitle:@"Server" Value:defaultServer Placeholder:@"http://example.com/exampleForms"];
        
        serverURLElement.keyboardType = UIKeyboardTypeURL;
    }
    serverURLElement.key = @"serverURL";
    serverURLElement.autocapitalizationType = UITextAutocapitalizationTypeNone;
    serverURLElement.autocorrectionType = UITextAutocorrectionTypeNo;
    [section addElement:serverURLElement];

    //TODO: add username, password, 2auth fields in future

    QButtonElement * addServerButton = [[QButtonElement alloc] initWithTitle:@"Add Server"];
    addServerButton.controllerAction = @"submitServer:";
    [section addElement:addServerButton];

    [elem addSection:section];

    return elem;
}

@end
