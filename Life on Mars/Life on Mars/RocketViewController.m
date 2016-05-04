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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *backgroundAfterAnimation;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rocketHeightConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *rocketImage;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UIImageView *fireImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fireHeightConstraint;

@end

@implementation RocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.fireImage.alpha = 0;
    self.fireImage.hidden = YES;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)redButtonTapped:(id)sender
{
    self.fireImage.hidden = NO;
    CGFloat screenHeight = self.backgroundImage.frame.size.height/5;
    CGFloat animationConstant = screenHeight * 4;
    
    self.backgroundAfterAnimation = [self.backgroundImage.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:animationConstant];
    self.backgroundAfterAnimation.active = NO;
    
    [self prepareAudio];
    [self.audioPlayer play];
    
    [UIView animateWithDuration:2.5 animations:^{
        self.fireImage.alpha = 1;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.33 animations:^{
            self.fireImage.alpha = 0;
            
            
        }];
    }];
    
    [UIView animateWithDuration:6.5 delay:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundBottomConstraint.active = NO;
        self.backgroundAfterAnimation.active = YES;
        
        self.rocketHeightConstraint.active = NO;
        [self.rocketImage.heightAnchor constraintEqualToConstant:0].active = YES;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        CATransition *transition = [CATransition animation];
        transition.duration = .8;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        [self.view.window.layer addAnimation:transition forKey:nil];
        [self performSegueWithIdentifier:@"segueToSpace" sender:self];
        
    }];
}

-(void)prepareAudio
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"launch" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
