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
#import <pop/POP.h>

@interface MarsViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *attributionTextView;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UIButton *rocketButton;
@property (weak, nonatomic) IBOutlet UIImageView *blackholeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *martianImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ufoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *alienImageView;
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
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
    self.blackholeImageView.userInteractionEnabled = YES;
    
    [self fetchMarsWeather];
    
    UITapGestureRecognizer *blackholeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBlackholeTapped:)];
    [self.blackholeImageView addGestureRecognizer:blackholeTapGestureRecognizer];
    blackholeTapGestureRecognizer.delegate = self;
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
    [self animateAlien];
}

#pragma mark - IBActions

- (IBAction)spaceshipTapped:(id)sender
{
    [self playAudio:@"powerup"];
    
    if (!self.buttonStackShowing) {
        
        self.buttonStackShowing = YES;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformTranslate(transform, -108, 0);
            
            self.buttonStackView.transform = transform;
        }];
        
    } else {
        
        self.buttonStackShowing = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.buttonStackView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (IBAction)rocketTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsTapped:(id)sender
{
    [self.attributionTextView setContentOffset:CGPointMake(0,0)];
    
    if (self.attributionTextView.hidden) {
        
        self.attributionTextView.hidden = NO;
        
    } else {
        
        self.attributionTextView.hidden = YES;
    }
}

#pragma mark - Animations

- (void)animateMartian
{
    __weak typeof(self) weakSelf = self;
    
    CGFloat transformationY = -(self.view.frame.size.height * 0.375 / 2);
    
    [UIView animateWithDuration:1 delay:3 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        transform = CGAffineTransformTranslate(transform, 0, transformationY);
        
        weakSelf.martianImageView.transform = transform;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            weakSelf.martianImageView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
            [weakSelf animateMartian];
        }];
    }];
}

- (void)animateBlackhole
{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        [weakSelf.blackholeImageView setTransform:CGAffineTransformRotate(self.blackholeImageView.transform, M_PI_2)];
        
    } completion:^(BOOL finished) {
        
        [weakSelf animateBlackhole];
    }];
}

- (void)animateUFO
{
    __weak typeof(self) weakSelf = self;
    
    CGFloat transformationY = -((self.view.frame.size.height + 50) / 2);
    
    if (weakSelf.ufoAnimationCounter % 2 == 0) {
        
        [UIView animateWithDuration:3 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformTranslate(transform, self.view.frame.size.width + 300, transformationY);
            transform = CGAffineTransformScale(transform, 0.1, 0.1);
            
            weakSelf.ufoImageView.transform = transform;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:3 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
                
                weakSelf.ufoImageView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                weakSelf.ufoAnimationCounter++;
                
                [weakSelf animateUFO];
            }];
        }];
        
    } else {
        
        [UIView animateWithDuration:2 delay:5 options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformTranslate(transform, self.view.frame.size.width + 200, 0);
            
            weakSelf.ufoImageView.transform = transform;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
                
                weakSelf.ufoImageView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                weakSelf.ufoAnimationCounter++;
                
                [weakSelf animateUFO];
            }];
        }];
    }
}

- (void)animateAlien
{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:2 delay:16 options:UIViewAnimationOptionCurveLinear animations:^{
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        transform = CGAffineTransformTranslate(transform, -self.view.frame.size.width - 200, 0);
        
        weakSelf.alienImageView.transform = transform;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2 delay:15 options:UIViewAnimationOptionCurveLinear animations:^{
            
            weakSelf.alienImageView.transform = CGAffineTransformIdentity;
            
        } completion:nil];
    }];
}

- (void)handleBlackholeTapped:(UITapGestureRecognizer *)recognizer
{
    [self.blackholeImageView pop_removeAllAnimations];
    self.blackholeImageView.userInteractionEnabled = NO;
    
    POPSpringAnimation *blackholeSpringShrink = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    blackholeSpringShrink.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    blackholeSpringShrink.velocity = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
    blackholeSpringShrink.springBounciness = 30.f;
    blackholeSpringShrink.autoreverses = YES;
    blackholeSpringShrink.springSpeed = 2;
    blackholeSpringShrink.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        self.blackholeImageView.userInteractionEnabled = YES;
        [self.blackholeImageView pop_removeAllAnimations];
    };
    
    POPSpringAnimation *blackholeSpringGrow = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    blackholeSpringGrow.toValue = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
    blackholeSpringGrow.velocity = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
    blackholeSpringGrow.springBounciness = 30.f;
    blackholeSpringGrow.autoreverses = YES;
    blackholeSpringGrow.springSpeed = 2;
    blackholeSpringGrow.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        [self.blackholeImageView pop_addAnimation:blackholeSpringShrink forKey:@"reverse"];
    };
    
    [self.blackholeImageView pop_addAnimation:blackholeSpringGrow forKey:@"spring"];
}

#pragma mark - API

-(void)fetchMarsWeather
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager GET:MARS_API parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self saveTemperaturesFromWeatherReport:responseObject[@"report"]];
        [self updateLabelsWithWeatherReport:responseObject[@"report"]];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self displayErrorAlert:error];
    }];
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
        
    } else {
        
        self.minTempLabel.text = [NSString stringWithFormat:@"Low: %@°F", self.minTempFar];
        self.maxTempLabel.text = [NSString stringWithFormat:@"High: %@°F", self.maxTempFar];
    }
}

- (IBAction)tempLabelTapped:(UITapGestureRecognizer *)sender
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

- (void)updateTemperatureScale
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

@end
