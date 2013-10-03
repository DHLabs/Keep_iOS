//
//  DHTextQuestionController.h
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHQuestionViewController.h"

@interface DHTextQuestionController : DHQuestionViewController

@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, assign) NSInteger afterDecimal;
@property (nonatomic, assign) BOOL isNumeric;

@end
