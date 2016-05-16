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
    
    [self playAudio:@"rocketLaunch"];
    
    [UIView animateWithDuration:1.6 animations:^{
        
        self.fireImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.fireImageView.alpha = 0;
        }];
    }];
    
    [UIView animateWithDuration:5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGAffineTransform backgroundTransform = CGAffineTransformIdentity;
        CGAffineTransform rocketTransform = CGAffineTransformIdentity;
        
        backgroundTransform = CGAffineTransformTranslate(backgroundTransform, 0, self.backgroundImageView.frame.size.height - self.view.frame.size.height);
        
        rocketTransform = CGAffineTransformTranslate(rocketTransform, 0, -self.view.frame.size.height/2);
        rocketTransform = CGAffineTransformScale(rocketTransform, 0.2, 0.2);
        
        self.backgroundImageView.transform = backgroundTransform;
        self.rocketImageView.transform = rocketTransform;
        
    } completion:^(BOOL finished) {
        
            [self performSegueWithIdentifier:@"segueToSpace" sender:self];
        }];
}

- (IBAction)teleportTapped:(id)sender
{
    [self performSegueWithIdentifier:@"segueToSpace" sender:self];
}

#pragma mark - Audio Set-Up

- (void)playAudio:(NSString *)soundName
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

@end
