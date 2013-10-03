//
//  DHMediaQuestionController.h
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Rich Stoner. All rights reserved.
//

#import "DHQuestionViewController.h"

@interface DHMediaQuestionController : DHQuestionViewController

//1 for image, 2 for video, 3 for audio
@property (nonatomic, assign) int mediaType;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) UIViewController * controller;

@end
