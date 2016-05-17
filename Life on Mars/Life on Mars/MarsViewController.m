//
//  MarsViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "MarsViewController.h"
#import "JBFConstants.h"
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface MarsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *attributionTextView;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UIStackView *temperatureStackViw;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UIButton *rocketButton;
@property (weak, nonatomic) IBOutlet UIImageView *martianImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ufoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blackholeImageView;
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *temperatureTapGestureRecognizer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) NSUInteger ufoAnimationCounter;
@property (assign, nonatomic) BOOL buttonStackShowing;
@property (strong, nonatomic) NSString *minTempFar;
@property (strong, nonatomic) NSString *maxTempFar;
@property (strong, nonatomic) NSString *minTempCel;
@property (strong, nonatomic) NSString *maxTempCel;

@end

@implementation MarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ufoAnimationCounter = 0;
    self.buttonStackShowing = NO;
    self.attributionTextView.hidden = YES;
    
    [self fetchMarsWeather];
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
    [self playAudio:@"powerup"];
    
    if (!self.buttonStackShowing) {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformTranslate(transform, -108, 0);
            
            self.buttonStackView.transform = transform;
            
            self.buttonStackShowing = YES;
            
        } completion:nil];
        
    } else {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.buttonStackView.transform = CGAffineTransformIdentity;
            self.buttonStackShowing = NO;
            
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
    CGFloat transformationY = -(self.view.frame.size.height * 0.375 / 2);
    
    [UIView animateWithDuration:1
                          delay:3
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformIdentity;
                         
                         transform = CGAffineTransformTranslate(transform, 0, transformationY);
                         
                         self.martianImageView.transform = transform;
                         
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
    CGFloat transformationY = -((self.view.frame.size.height + 50) / 2);
    
    if (self.ufoAnimationCounter % 2 == 0) {
        
        [UIView animateWithDuration:2 delay:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformTranslate(transform, self.view.frame.size.width + 300, transformationY);
            
            transform = CGAffineTransformScale(transform, 0.1, 0.1);
            
            self.ufoImageView.transform = transform;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.ufoImageView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                self.ufoAnimationCounter++;
                
                [self animateUFO];
            }];
        }];
        
    } else {
        
        [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.ufoImageView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width + 300, 0);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
                
                self.ufoImageView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                self.ufoAnimationCounter++;
                
                [self animateUFO];
            }];
        }];
    }
}

#pragma mark - Update Labels
- (void)saveTemperaturesFromWeatherReport:(NSDictionary *)marsDictionary
{
    self.minTempFar = marsDictionary[@"min_temp_fahrenheit"];
    self.maxTempFar = marsDictionary[@"max_temp_fahrenheit"];
    self.minTempCel = marsDictionary[@"min_temp"];
    self.maxTempCel = marsDictionary[@"max_temp"];
}

- (void)updateLabelsWithWeatherReport:(NSDictionary *)marsDictionary
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = marsDictionary[@"terrestrial_date"];
    NSDate *earthDate = [dateFormatter dateFromString:dateString];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *newDate = [dateFormatter stringFromDate:earthDate];
    
    self.weatherLabel.text = [NSString stringWithFormat:@"The weather on Mars is %@", marsDictionary[@"atmo_opacity"]];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@", newDate];
    
    NSString *temperaturePreference = [[NSUserDefaults standardUserDefaults] objectForKey:TEMP_SCALE_KEY];
    
    if ([temperaturePreference isEqualToString:CEL] || !temperaturePreference) {
        
        self.minTempLabel.text = [NSString stringWithFormat:@"Low: %@°C", self.minTempCel];
        self.maxTempLabel.text = [NSString stringWithFormat:@"High: %@°C", self.maxTempCel];
        
    }
    else {
        
        self.minTempLabel.text = [NSString stringWithFormat:@"Low: %@°F", self.minTempFar];
        self.maxTempLabel.text = [NSString stringWithFormat:@"High: %@°F", self.maxTempFar];
    }
}

- (IBAction)temperatureStackViewTapped:(UITapGestureRecognizer *)sender
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.25;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.minTempLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [self.maxTempLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    NSString *temperaturePreference = [[NSUserDefaults standardUserDefaults] objectForKey:TEMP_SCALE_KEY];
    
    if ([temperaturePreference isEqualToString:CEL] || !temperaturePreference) {
        
        self.minTempLabel.text = [NSString stringWithFormat:@"Low: %@°F", self.minTempFar];
        self.maxTempLabel.text = [NSString stringWithFormat:@"High: %@°F", self.maxTempFar];
        
        [[NSUserDefaults standardUserDefaults] setValue:FAR forKey:TEMP_SCALE_KEY];
        
    } else {
        
        self.minTempLabel.text = [NSString stringWithFormat:@"Low: %@°C", self.minTempCel];
        self.maxTempLabel.text = [NSString stringWithFormat:@"High: %@°C", self.maxTempCel];
        
        [[NSUserDefaults standardUserDefaults] setValue:CEL forKey:TEMP_SCALE_KEY];
    }
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

#pragma mark - Audio

- (void)playAudio:(NSString *)soundName
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

#pragma mark - API

-(void)fetchMarsWeather
{
AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
[sessionManager GET:MARS_API parameters:nil progress:^(NSProgress *downloadProgress) {
    
} success:^(NSURLSessionDataTask *task, id responseObject) {
    [self saveTemperaturesFromWeatherReport:responseObject[@"report"]];
    [self updateLabelsWithWeatherReport:responseObject[@"report"]];
    
} failure:^(NSURLSessionDataTask *task, NSError *error) {
    
    [self displayErrorAlert:error];
}];
}

@end
