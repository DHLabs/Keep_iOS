//
//  DHMiscUtilities.m
//  Keep
//
//  Created by Sean Patno on 6/26/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHMiscUtilities.h"

#import "AFHTTPRequestOperation.h"
#import "SVProgressHUD.h"
#import "XMLReader.h"
//#import "DHSurveyViewController.h"
#import "XFormJSONConverter.h"
#import "FormDownloader.h"

@interface DHMiscUtilities()

//+(void) downloadForm:(ODKForm *)form completion

@end

@implementation DHMiscUtilities

//static int numDownloads = 0;
//static ODKForm * formToShow;
//static UIViewController * viewController;

+(void) downloadForm:(KeepForm *)form completion:(void (^)(void))completion
{
    
}

+(void) downloadFormsForServer:(KeepServer *)server completion:(void (^)(void))completion
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];

    int __block downloads = [server.forms count];

    if( downloads == 0 ) {
        [SVProgressHUD dismiss];
        return;
    }
    
    for( KeepForm * form in server.forms ) {
        [FormDownloader downloadForm:form completion:^() {
            downloads--;
            if( downloads == 0 ) {
                [SVProgressHUD dismiss];
                [completion invoke];
                
            }
        } failure:^(NSError *error) {
            downloads--;
            if( downloads == 0 ) {
                [SVProgressHUD dismiss];
                [completion invoke];
            }
        }];
    }
}

+(void) showForm:(KeepForm*) form fromController:(UIViewController*) controller storedForm:(StoredForm*)storedForm
{
    @try {
        //DHQDViewController * formController = [[DHQDViewController alloc] initWithODKForm:form];
        //formController.formDelegate = self;

        /*DHSurveyViewController * formController = [[DHSurveyViewController alloc] init];

        NSLog(@"form json: %@", [XFormJSONConverter JSONFormFromXMLPath:[form.formPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", form.formID]]]);

        formController.form = form;
        formController.storedForm = storedForm;

        [controller.navigationController pushViewController:formController animated:YES];*/
    }
    @catch (NSException *exception) {

        NSLog(@"Exception: %@", exception);
        NSLog(@"stack trace: %@", [exception callStackSymbols]);

        [controller.navigationController popViewControllerAnimated:NO];

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This form is not supported yet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

+(void) presentForm:(KeepForm *)form fromController:(UIViewController *)controller withStored:(StoredForm *)storedForm
{
    if( form.formPath  ) {
        [DHMiscUtilities showForm:form fromController:controller storedForm:storedForm];

    } else {
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
        [FormDownloader downloadForm:form completion:^() {
            [SVProgressHUD dismiss];
            [DHMiscUtilities showForm:form fromController:controller storedForm:storedForm];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }];
    }
}

+(void) presentForm:(KeepForm *)form fromController:(UIViewController*) controller
{
    [DHMiscUtilities presentForm:form fromController:controller withStored:nil];
}



@end
