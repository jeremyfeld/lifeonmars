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
@property (weak, nonatomic) IBOutlet UIButton *onboardingGoButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *teleportLabel;
@property (weak, nonatomic) IBOutlet UILabel *launchLabel;
@property (weak, nonatomic) IBOutlet UIView *onboardingContainerView;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *onboardingLabelFour;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) NSUInteger nextTappedCounter;

@end

@implementation RocketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.nextTappedCounter = 0;
    
    self.rocketImageView.transform = CGAffineTransformIdentity;
    self.backgroundImageView.transform = CGAffineTransformIdentity;
    
    BOOL shouldSkipOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:ONBOARD_COMPLETE_KEY];
    
    if (shouldSkipOnboarding) {
        
        self.onboardingContainerView.alpha = 0;
        
    } else {
        
        self.onboardingLabelTwo.alpha = 0;
        self.onboardingLabelThree.alpha = 0;
        self.onboardingLabelFour.alpha = 0;
    }
    
    self.fireImageView.alpha = 0;
    self.redButton.userInteractionEnabled = YES;
    self.teleportButton.userInteractionEnabled = YES;
    self.redButton.hidden = NO;
    self.launchLabel.hidden = NO;
    
    BOOL shouldShowTeleport = [[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LAUNCHED_KEY];
    
    if (shouldShowTeleport) {
        
        self.teleportButton.hidden = NO;
        self.teleportLabel.hidden = NO;
        
    } else {
        
        self.teleportButton.hidden = YES;
        self.teleportLabel.hidden = YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)onboardingRocketTapped:(id)sender
{
    [UIView animateWithDuration:1 animations:^{
        
        self.onboardingContainerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ONBOARD_COMPLETE_KEY];
    }];
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
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_HAS_LAUNCHED_KEY];
        [self performSegueWithIdentifier:@"segueToSpace" sender:self];
    }];
}

- (IBAction)teleportTapped:(id)sender
{
    [self performSegueWithIdentifier:@"segueToSpace" sender:self];
}

- (IBAction)nextButtonTapped:(id)sender
{
    self.nextTappedCounter++;
    
    [self displayOnboardingLabels];
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
    if (self.nextTappedCounter == 1) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.onboardingLabelOne.alpha = 0;
            self.onboardingLabelTwo.alpha = 1;
        }];
        
    } else if (self.nextTappedCounter == 2) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.onboardingLabelTwo.alpha = 0;
            self.onboardingLabelThree.alpha = 1;
        }];
        
    } else if (self.nextTappedCounter == 3) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.onboardingLabelThree.alpha = 0;
            self.onboardingLabelFour.alpha = 1;
            self.nextButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:3 animations:^{
                
                CGAffineTransform transform = CGAffineTransformIdentity;
                
                transform = CGAffineTransformTranslate(transform, 0, -self.view.frame.size.height);
                
                self.onboardingGoButton.transform = transform;
            }];
            
        }];
    }
}

@end
