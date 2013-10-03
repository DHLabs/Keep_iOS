//
//  DHTextQuestionController.m
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHTextQuestionController.h"

@interface DHTextQuestionController () <UITextFieldDelegate>
{
    UITextField * theTextField;
}

@end

@implementation DHTextQuestionController

-(id) questionAnswer
{
    if( theTextField.text ) {
        if( [theTextField.text isEqualToString:@""] ) {
            return nil;
        }
    }

    return theTextField.text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CGRect rect = CGRectMake(10, self.labelController.view.frame.size.height + 20.0, [UIScreen mainScreen].bounds.size.width - 20.0, 40);
    theTextField = [[UITextField alloc] initWithFrame:rect];
    //textField.backgroundColor = [UIColor whiteColor];
    theTextField.font = [UIFont boldSystemFontOfSize:26.0];
    theTextField.borderStyle = UITextBorderStyleRoundedRect;
    theTextField.textColor = [UIColor blackColor];
    theTextField.keyboardType = self.keyboardType;
    theTextField.delegate = self;
    
    if( self.defaultValue ) {
        theTextField.text = self.defaultValue;
    }

    [self.scrollView addSubview:theTextField];
    [self resizeQuestionView];
}

-(void) questionWillDisappear
{
    [theTextField resignFirstResponder];
}

-(void) questionDidShow
{
    [theTextField becomeFirstResponder];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if( self.isNumeric ) {

        if( [newString isEqualToString:@""] ) {
            return YES;
        }
        
        if( ![[[NSNumberFormatter alloc] init] numberFromString:newString] ) {
            return NO;
        }

        if( [textField.text rangeOfString:@"."].location != NSNotFound && [string rangeOfString:@"."].location != NSNotFound ) {
            return NO;
        }
    }
    NSString * newAnswer;
    if( [newString isEqualToString:@""] ) {
        newAnswer = nil;
    } else {
        newAnswer = newString;
    }

    return YES;
}


@end
