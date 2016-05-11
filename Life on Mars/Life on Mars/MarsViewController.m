//
//  MarsViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "MarsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface MarsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *attributionTextView;
@property (weak, nonatomic) IBOutlet UILabel *minFarLabel;
@property (weak, nonatomic) IBOutlet UILabel *minCelLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxFarLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxCelLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UIButton *rocketButton;
@property (weak, nonatomic) IBOutlet UIImageView *martianImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ufoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blackholeImageView;
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ufoWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonStackViewTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *ufoWidthAfterAnimationConstraint;
@property (strong, nonatomic) NSLayoutConstraint *buttonStackAfterAnimationConstraint;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) NSUInteger ufoAnimationCounter;

@end

@implementation MarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ufoWidthAfterAnimationConstraint.active = NO;
    self.ufoWidthAfterAnimationConstraint = [self.ufoImageView.widthAnchor constraintEqualToConstant:5];
    self.buttonStackAfterAnimationConstraint.active = NO;
    self.buttonStackAfterAnimationConstraint = [self.buttonStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10];
    
    self.ufoAnimationCounter = 0;
    
    self.attributionTextView.hidden = YES;
    
    NSString *marsWeather = [NSString stringWithFormat:@"http://marsweather.ingenology.com/v1/latest/"];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager GET:marsWeather parameters:nil progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *marsWeatherDictionary = responseObject[@"report"];
        [self updateLabelsWithDictionary:marsWeatherDictionary];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self displayErrorAlert:error];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self animateMartian];
    [self animateBlackhole];
    [self animateUFO];
    
}

#pragma mark - IBActions

- (IBAction)spaceshipTapped:(id)sender
{
    [self prepareAudio:@"ray"];
    [self.audioPlayer play];
    
    if (self.buttonStackViewTrailingConstraint.active) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.buttonStackViewTrailingConstraint.active = NO;
            self.buttonStackAfterAnimationConstraint.active = YES;
            
            [self.view layoutIfNeeded];
            
        } completion:nil];
        
    } else {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.buttonStackAfterAnimationConstraint.active = NO;
            self.buttonStackViewTrailingConstraint.active = YES;
            
            [self.view layoutIfNeeded];
            
        } completion:nil];
    }
}

- (IBAction)rocketTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsTapped:(id)sender
{
    if (self.attributionTextView.hidden) {
        
        self.attributionTextView.hidden = NO;
        
    } else {
        
        self.attributionTextView.hidden = YES;
    }
}

#pragma mark - Animations

- (void)animateMartian
{
    CGFloat centerY = self.view.frame.size.height * 0.75 / 2;
    CGFloat newY = self.view.frame.size.height * 0.375 / 2;
    CGFloat transformationY = centerY - newY;
    
    [UIView animateWithDuration:1
                          delay:4
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.martianImageView.transform = CGAffineTransformMakeTranslation(0, -transformationY);
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              
                                              self.martianImageView.transform = CGAffineTransformIdentity;
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              [self animateMartian];
                                          }];
                     }];
}

- (void)animateBlackhole
{
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [self.blackholeImageView setTransform:CGAffineTransformRotate(self.blackholeImageView.transform, M_PI_2)];
                         
                     } completion:^(BOOL finished) {
                         
                         [self animateBlackhole];
                     }];
}

- (void)animateUFO
{
    CGFloat centerY = self.view.frame.size.height / 2;
    CGFloat transformationY = 0 - centerY;
    
    if (self.ufoAnimationCounter % 2 == 0) {
        
        [UIView animateWithDuration:6
                              delay:8
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.ufoImageView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width+300, transformationY);
                             
                             self.ufoWidthConstraint.active = NO;
                             self.ufoWidthAfterAnimationConstraint.active = YES;
                             
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:6
                                                   delay:7
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  
                                                  self.ufoImageView.transform = CGAffineTransformIdentity;
                                                  self.ufoWidthAfterAnimationConstraint.active = NO;
                                                  self.ufoWidthConstraint.active = YES;
                                                  
                                                  [self.view layoutIfNeeded];
                                                  
                                              } completion:^(BOOL finished) {
                                                  
                                                  self.ufoAnimationCounter ++;
                                                  
                                                  [self animateUFO];
                                              }];
                         }];
        
    } else {
        
        [UIView animateWithDuration:3
                              delay:8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             self.ufoImageView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width+300, 0);
                             
                         } completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:3
                                                   delay:7
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  
                                                  self.ufoImageView.transform = CGAffineTransformIdentity;
                                                                                                    
                                              } completion:^(BOOL finished) {
                                                  
                                                  self.ufoAnimationCounter ++;
                                                  
                                                  [self animateUFO];
                                              }];
                         }];
    }
}

#pragma mark - Update Labels

- (void)updateLabelsWithDictionary:(NSDictionary *)marsDictionary
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = marsDictionary[@"terrestrial_date"];
    NSDate *earthDate = [dateFormatter dateFromString:dateString];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *newDate = [dateFormatter stringFromDate:earthDate];
    
    self.minCelLabel.text = [NSString stringWithFormat:@"Low: %@ °C", marsDictionary[@"min_temp"]];
    self.minFarLabel.text = [NSString stringWithFormat:@"Low: %@ °F", marsDictionary[@"min_temp_fahrenheit"]];
    self.maxCelLabel.text = [NSString stringWithFormat:@"High: %@ °C", marsDictionary[@"max_temp"]];
    self.maxFarLabel.text = [NSString stringWithFormat:@"High: %@ °F", marsDictionary[@"max_temp_fahrenheit"]];
    self.weatherLabel.text = [NSString stringWithFormat:@"The weather on Mars is %@", marsDictionary[@"atmo_opacity"]];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@", newDate];
}

#pragma mark - Error Handling
     
- (void)displayErrorAlert:(NSError *)error
{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:[NSString stringWithFormat:@"There was an error loading the data: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [errorAlert addAction:dismissAction];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

#pragma mark - Audio Set-Up

- (void)prepareAudio:(NSString *)soundName
{
    NSDataAsset *soundAsset = [[NSDataAsset alloc] initWithName:soundName];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundAsset.data error:nil];
    [self.audioPlayer prepareToPlay];
}

@end
