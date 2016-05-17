//
//  RocketViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/4/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "RocketViewController.h"
#import "JBFConstants.h"
#import <AVFoundation/AVFoundation.h>

@interface RocketViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rocketImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fireImageView;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *teleportButton;
@property (weak, nonatomic) IBOutlet UIButton *onboardingRocketButton;
@property (weak, nonatomic) IBOutlet UILabel *teleportLabel;
@property (weak, nonatomic) IBOutlet UILabel *launchLabel;
@property (weak, nonatomic) IBOutlet UIView *onboardingContainerView;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelFour;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fireHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rocketHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rocketBottomConstraint;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation RocketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.rocketImageView.transform = CGAffineTransformIdentity;
    self.backgroundImageView.transform = CGAffineTransformIdentity;
    
    BOOL shouldSkipOnboarding = [[NSUserDefaults standardUserDefaults] valueForKey:ONBOARD_COMPLETE_KEY];
    
    if (shouldSkipOnboarding) {
        self.onboardingContainerView.alpha = 0;
    } else {
        self.onboardingLabelTwo.alpha = 0;
        self.onboardingLabelThree.alpha = 0;
        self.onboardingLabelFour.alpha = 0;
        [self displayOnboardingLabels];
    }
    
    self.fireImageView.alpha = 0;
    
    self.redButton.userInteractionEnabled = YES;
    self.teleportButton.userInteractionEnabled = YES;
    self.redButton.hidden = NO;
    self.launchLabel.hidden = NO;
    self.teleportButton.hidden = NO;
    self.teleportLabel.hidden = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)onboardingRocketTapped:(id)sender
{
}

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

#pragma mark - Onboarding

- (void)displayOnboardingLabels
{
    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.onboardingLabelOne.alpha = 0;
        self.onboardingLabelTwo.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.onboardingLabelTwo.alpha = 0;
            self.onboardingLabelThree.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 delay:7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.onboardingLabelThree.alpha = 0;
                self.onboardingLabelFour.alpha = 1;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:3 animations:^{
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformTranslate(transform, 0, -self.view.frame.size.height);
                    
                    self.onboardingRocketButton.transform = transform;
                }];

            }];
        }];
    }];
}

@end
