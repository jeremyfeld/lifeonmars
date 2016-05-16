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

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rocketImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fireImageView;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *teleportButton;
@property (weak, nonatomic) IBOutlet UILabel *teleportLabel;
@property (weak, nonatomic) IBOutlet UILabel *launchLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fireHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rocketHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rocketBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *backgroundAfterAnimation;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation RocketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fireImageView.alpha = 0;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)redButtonTapped:(id)sender
{
    self.redButton.userInteractionEnabled = NO;
    self.teleportButton.userInteractionEnabled = NO;
    self.redButton.hidden = YES;
    self.launchLabel.hidden = YES;
    self.teleportButton.hidden = YES;
    self.teleportLabel.hidden = YES;
    
    CGFloat screenHeight = self.backgroundImageView.frame.size.height/5;
    CGFloat animationConstant = screenHeight * 4;
    
    self.backgroundAfterAnimation = [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:animationConstant];
    self.backgroundAfterAnimation.active = NO;
    
    [self prepareAudio:@"launch"];
    [self.audioPlayer play];
    
    [UIView animateWithDuration:2.1 animations:^{
        
        self.fireImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.fireImageView.alpha = 0;
        }];
    }];
    
    [UIView animateWithDuration:1
                          delay:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.rocketBottomConstraint.active = NO;
                         
                         [self.rocketImageView.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:50].active = YES;
                                                                           
                     } completion:nil];
    
    [UIView animateWithDuration:7
                          delay:2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.backgroundBottomConstraint.active = NO;
                         self.backgroundAfterAnimation.active = YES;
                         
                         self.rocketHeightConstraint.active = NO;
                         [self.rocketImageView.heightAnchor constraintEqualToConstant:0].active = YES;
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         self.redButton.userInteractionEnabled = YES;
                         self.teleportButton.userInteractionEnabled = YES;
                         self.redButton.hidden = NO;
                         self.launchLabel.hidden = NO;
                         self.teleportButton.hidden = NO;
                         self.teleportLabel.hidden = NO;
                         
//                         CATransition *transition = [CATransition animation];
//                         transition.duration = .8;
//                         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//                         transition.type = kCATransitionPush;
//                         transition.subtype = kCATransitionFromBottom;
//                         
//                         [self.view.window.layer addAnimation:transition forKey:nil];
                         
                         
                         // FADE TO BLACK HERE AND THEN PRESENT
                         
                         [self performSegueWithIdentifier:@"segueToSpace" sender:self];
                     }];
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

#pragma mark - Audio Set-Up

- (void)prepareAudio:(NSString *)soundName
{
    NSDataAsset *soundAsset = [[NSDataAsset alloc] initWithName:soundName];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundAsset.data error:nil];
    [self.audioPlayer prepareToPlay];
}

@end
