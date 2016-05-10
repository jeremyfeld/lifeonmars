//
//  RocketViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/4/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "RocketViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RocketViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIImageView *rocketImage;
@property (strong, nonatomic) IBOutlet UIImageView *fireImage;
@property (strong, nonatomic) IBOutlet UITextView *attributionTextView;
@property (strong, nonatomic) IBOutlet UIButton *redButton;
@property (strong, nonatomic) IBOutlet UIButton *teleportButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UILabel *teleportLabel;
@property (strong, nonatomic) IBOutlet UILabel *launchLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fireHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rocketHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rocketBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *backgroundAfterAnimation;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation RocketViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.fireImage.alpha = 0;
    self.attributionTextView.hidden = YES;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction)redButtonTapped:(id)sender
{
    self.redButton.userInteractionEnabled = NO;
    self.teleportButton.userInteractionEnabled = NO;
    self.infoButton.hidden = YES;
    self.redButton.hidden = YES;
    self.launchLabel.hidden = YES;
    self.teleportButton.hidden = YES;
    self.teleportLabel.hidden = YES;
    
    CGFloat screenHeight = self.backgroundImage.frame.size.height/5;
    CGFloat animationConstant = screenHeight * 4;
    
    self.backgroundAfterAnimation = [self.backgroundImage.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:animationConstant];
    self.backgroundAfterAnimation.active = NO;
    
    [self prepareAudio];
    [self.audioPlayer play];
    
    [UIView animateWithDuration:2.1 animations:^{
        
        self.fireImage.alpha = 1;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.fireImage.alpha = 0;
        }];
    }];
    
    [UIView animateWithDuration:1 delay:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.rocketBottomConstraint.active = NO;
        
        [self.rocketImage.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:50].active = YES;
        
    } completion:^(BOOL finished) {
        //
    }];
    
    [UIView animateWithDuration:7 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.backgroundBottomConstraint.active = NO;
        self.backgroundAfterAnimation.active = YES;
        
        self.rocketHeightConstraint.active = NO;
        [self.rocketImage.heightAnchor constraintEqualToConstant:0].active = YES;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        self.redButton.userInteractionEnabled = YES;
        self.teleportButton.userInteractionEnabled = YES;
        self.infoButton.hidden = NO;
        self.redButton.hidden = NO;
        self.launchLabel.hidden = NO;
        self.teleportButton.hidden = NO;
        self.teleportLabel.hidden = NO;
        
        CATransition *transition = [CATransition animation];
        transition.duration = .8;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        
        [self.view.window.layer addAnimation:transition forKey:nil];
        [self performSegueWithIdentifier:@"segueToSpace" sender:self];
    }];
}

- (IBAction)infoTapped:(id)sender
{
    if (self.attributionTextView.hidden) {
        
        self.attributionTextView.hidden = NO;
        
    } else {
        
        self.attributionTextView.hidden = YES;
    }
}

- (IBAction)teleportTapped:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = .8;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self performSegueWithIdentifier:@"segueToSpace" sender:self];
}

-(void)prepareAudio
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"launch" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
}

@end
