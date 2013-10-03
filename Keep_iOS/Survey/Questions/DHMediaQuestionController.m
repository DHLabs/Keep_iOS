//
//  DHMediaQuestionController.m
//  Keep
//
//  Created by Sean Patno on 5/7/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHMediaQuestionController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

//TODO: support for audio and video selection

@interface DHMediaQuestionController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSURL * mediaPath;
    UIImageView * imageView;
    UIPopoverController *popover;
    UIButton * libraryButton;
    UIButton * movieButton;
}

-(void) takePicture;
-(void) selectPicFromLibrary;

@end

@implementation DHMediaQuestionController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSString * buttonTitle;
    if( self.mediaType == 1 ) {
        buttonTitle = @"Take Picture";
    } else if( self.mediaType == 2 ) {
        buttonTitle = @"Take Video";
    } else {
        buttonTitle = @"Capture Audio";
    }

    UIButton * cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cameraButton.frame = CGRectMake(self.view.frame.size.width/2 - 150, self.labelController.view.frame.size.height + 10.0, 300, 50.0);
    [cameraButton setTitle:buttonTitle forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];

    [self.scrollView addSubview:cameraButton];

    mediaPath = self.defaultValue;

    if( self.mediaType != 3 ) {

        libraryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        libraryButton.frame = CGRectMake(self.view.frame.size.width/2 - 150, cameraButton.frame.origin.y + cameraButton.frame.size.height + 10.0, 300.0, 50.0);
        [libraryButton setTitle:@"Select From Library" forState:UIControlStateNormal];
        [libraryButton addTarget:self action:@selector(selectPicFromLibrary) forControlEvents:UIControlEventTouchUpInside];

        [self.scrollView addSubview:libraryButton];
    }

    if( self.mediaType == 1 ) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 150, libraryButton.frame.origin.y + libraryButton.frame.size.height + 10.0, 300,300)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if( self.defaultValue ) {
            imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.defaultValue]];
        }

        [self.scrollView addSubview:imageView];
    }

    if( self.mediaType == 2 ) {
        movieButton = [UIButton buttonWithType:UIButtonTypeCustom];
        movieButton.frame = CGRectMake(self.view.frame.size.width/2 - 150, libraryButton.frame.origin.y + libraryButton.frame.size.height + 10.0, 300,300);
        [movieButton addTarget:self action:@selector(doMoviePlayback) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:movieButton];

        if( !mediaPath ) {
            movieButton.enabled = NO;
        }
        
    }
}

-(id) questionAnswer
{
    return mediaPath;
}

-(void) takePicture
{
    [self captureMedia:NO];
}

-(void) doMoviePlayback {
    NSLog(@"do movie playback");
    MPMoviePlayerController * movie = [[MPMoviePlayerController alloc] initWithContentURL:mediaPath];

    [movie setFullscreen:YES animated:YES];
}

-(void) selectPicFromLibrary {
    [self captureMedia:YES];
}

-(void) captureMedia:(BOOL) fromLibrary
{
    //TODO: put in popover controller for iPad, required or will break

    if ([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        return;

    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];

    if( fromLibrary ) {
        cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        NSLog(@"camera");
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }

    if( self.mediaType == 2 ) {
        NSLog(@"video");
        cameraController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        //cameraController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    } else {
        cameraController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
    }    
    cameraController.allowsEditing = NO;
    cameraController.delegate = self;

    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && fromLibrary ) {
        popover = [[UIPopoverController alloc] initWithContentViewController:cameraController];
        //popover.delegate = self;
        [popover presentPopoverFromRect:libraryButton.frame
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    } else {
       // [self.controller presentModalViewController:cameraController animated:YES];
        NSLog(@"tetst");
        [self.controller presentViewController:cameraController animated:YES completion:NO];
        NSLog(@"hello");
    }

    //[self.navigationController presentModalViewController:cameraController animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{

}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];
    if( popover ) {
        [popover dismissPopoverAnimated:YES];
    } else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    //TODO: possibly just save to camera roll, that way it's not stored in our path, and it provides an easy method of deleting that file

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSData * webData;
    NSString *fileExtension;
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo)
    {
        NSURL * url  = [info objectForKey:@"UIImagePickerControllerMediaURL"];
        webData = [NSData dataWithContentsOfURL:url];
        fileExtension = @"mov";
    } else {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

        NSLog(@"image: %@", image);

        imageView.image = image;
        [imageView setNeedsDisplay];

        fileExtension = @"png";
        webData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    }
    if( !webData ) {
        NSLog(@"something went wrong");
    }

    NSString *documentsDirectory = self.path;

    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMMddhhmmss";

    NSString *filename = [format stringFromDate:[NSDate date]]; //[[currentPath componentsSeparatedByString:@"/"] lastObject];

    filename = [filename stringByAppendingString:[NSString stringWithFormat:@".%@", fileExtension]];

    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSLog(@"filename: %@", filename);
    [webData writeToFile:localFilePath atomically:YES];
    NSURL * newUrl = [NSURL fileURLWithPath:localFilePath];
    NSLog(@"new url: %@", newUrl);

    mediaPath = newUrl;

    if( popover ) {
        [popover dismissPopoverAnimated:YES];
    } else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }

    if( self.mediaType == 2 ) {
        [self buildVideoThumbButton];
        movieButton.enabled = YES;
    }
}

-(void) buildVideoThumbButton
{
    movieButton.imageView.image = [DHMediaQuestionController imageFromMovie:mediaPath atTime:0];
}

+ (UIImage *)imageFromMovie:(NSURL *)movieURL atTime:(NSTimeInterval)time {
    // set up the movie player
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc]
                                   initWithContentURL:movieURL];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = time;
    mp.currentPlaybackTime = time;
    // get the thumbnail
    UIImage *thumbnail = [mp thumbnailImageAtTime:time
                                       timeOption:MPMovieTimeOptionNearestKeyFrame];
    // clean up the movie player
    [mp stop];
    return(thumbnail);
}


@end
