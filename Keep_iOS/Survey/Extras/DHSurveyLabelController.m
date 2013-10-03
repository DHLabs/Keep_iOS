//
//  DHSurveyLabelController.m
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHSurveyLabelController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface DHSurveyLabelController () <AVAudioPlayerDelegate>

//-(void) playSound:(id)sender;

@end

@implementation DHSurveyLabelController

-(void) loadView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.height = 100.0;
    rect.origin.y = 10.0;
    rect.origin.x = 10.0;
    rect.size.width -= 20.0;
    self.view = [[UIView alloc] initWithFrame:rect];

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if( self.label.labelString ) {
        [self addText];
    }

    if( self.label.imagePath ) {
        [self addImage];
    }

    if( self.label.audioPath ) {
        if( [[NSFileManager defaultManager] fileExistsAtPath:self.label.audioPath] ) {
            [self addAudio];
        }
    }

    if( self.label.videoPath ) {
        
    }
}

-(void) addText
{
    CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
    CGSize  size= [self.label.labelString sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGFloat predictedHeight = size.height + 10.0f;

    UILabel * labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, predictedHeight)];
    labelView.font = [UIFont boldSystemFontOfSize:18.0];
    labelView.text = self.label.labelString;
    //labelView.font = [UIFont fontWithName:@"Helvetica-regular" size:20.0];
    labelView.backgroundColor = [UIColor clearColor];
    labelView.numberOfLines = 0;
    labelView.lineBreakMode = UILineBreakModeWordWrap;
    [self.view addSubview:labelView];

    CGRect rect = self.view.frame;
    rect.size.height = predictedHeight + 10.0;
    self.view.frame = rect;
}

-(void) addImage
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, 80, 80.0)];

    UIImage * image = [UIImage imageWithContentsOfFile:self.label.imagePath];
    if(!image) {
        return;
    }
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0f;

    [self.view addSubview:imageView];
    CGRect rect = self.view.frame;
    rect.size.height += 100.0;
    self.view.frame = rect;
}

-(void) addVideo
{
    
}

-(void) playSound//:(id)sender
{
    NSURL * fileURL = [NSURL fileURLWithPath:self.label.audioPath];
   
    SystemSoundID soundID;

    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    AudioServicesPlaySystemSound (soundID);

}

-(void) addAudio
{
    //NSLog(@"audio length: %d", [[NSData dataWithContentsOfFile:self.label.audioPath] length]);

    if( [[NSData dataWithContentsOfFile:self.label.audioPath] length] < 6000 ) {
        return;
    }

    UIButton * playAudioButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playAudioButton setTitle:@"Play Sound" forState:UIControlStateNormal];
    playAudioButton.frame = CGRectMake(10.0, self.view.frame.size.height + 10.0, 100.0, 40.0);
    //playAudioButton.s
    [playAudioButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];

    //NSLog(@"targets: %@, actions: %d", playAudioButton.allTargets, playAudioButton.allControlEvents);
    
    [self.view addSubview:playAudioButton];
    CGRect rect = self.view.frame;
    rect.size.height += 70.0;
    self.view.frame = rect;
}

@end
