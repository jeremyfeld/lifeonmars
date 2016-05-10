//
//  MarsViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "MarsViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface MarsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *minFarLabel;
@property (weak, nonatomic) IBOutlet UILabel *minCelLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxFarLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxCelLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (strong, nonatomic) IBOutlet UIButton *rocketButton;
@property (strong, nonatomic) IBOutlet UIImageView *martianImageView;
@property (strong, nonatomic) IBOutlet UIImageView *ufoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *blackholeImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ufoWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *ufoWidthAfterAnimationConstraint;
@property (assign, nonatomic) NSUInteger ufoAnimationCounter;

@end

@implementation MarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ufoWidthAfterAnimationConstraint.active = NO;
    self.ufoWidthAfterAnimationConstraint = [self.ufoImageView.widthAnchor constraintEqualToConstant:5];
    self.ufoAnimationCounter = 0;
    
    NSString *marsWeather = [NSString stringWithFormat:@"http://marsweather.ingenology.com/v1/latest/"];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager GET:marsWeather parameters:nil progress:^(NSProgress *downloadProgress) {
        
        //add progress bar?
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *marsWeatherDictionary = responseObject[@"report"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = marsWeatherDictionary[@"terrestrial_date"];
        NSDate *earthDate = [dateFormatter dateFromString:dateString];
        dateFormatter.dateFormat = @"MM-dd-yyyy";
        NSString *newDate = [dateFormatter stringFromDate:earthDate];
        
        self.minCelLabel.text = [NSString stringWithFormat:@"Low: %@ °C", marsWeatherDictionary[@"min_temp"]];
        self.minFarLabel.text = [NSString stringWithFormat:@"Low: %@ °F", marsWeatherDictionary[@"min_temp_fahrenheit"]];
        self.maxCelLabel.text = [NSString stringWithFormat:@"High: %@ °C", marsWeatherDictionary[@"max_temp"]];
        self.maxFarLabel.text = [NSString stringWithFormat:@"High: %@ °F", marsWeatherDictionary[@"max_temp_fahrenheit"]];
        self.weatherLabel.text = [NSString stringWithFormat:@"The weather on Mars is %@", marsWeatherDictionary[@"atmo_opacity"]];
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@", newDate];
        
        self.minCelLabel.hidden = NO;
        self.minFarLabel.hidden = NO;
        self.maxCelLabel.hidden = NO;
        self.maxFarLabel.hidden = NO;
        self.weatherLabel.hidden = NO;
        self.lastUpdatedLabel.hidden = NO;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error: %@", error.localizedDescription);
        //error message
        
    }];
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self animateMartian];
    [self animateBlackhole];
    [self animateUFO];
    
}

- (IBAction)rocketTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)animateMartian
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
                         
                         [self.view layoutIfNeeded];
                         
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

-(void)animateBlackhole
{
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [self.blackholeImageView setTransform:CGAffineTransformRotate(self.blackholeImageView.transform, M_PI_2)];
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         [self animateBlackhole];
                     }];
}

-(void)animateUFO
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
                             
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:3
                                                   delay:7
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  
                                                  self.ufoImageView.transform = CGAffineTransformIdentity;
                                                  
                                                  [self.view layoutIfNeeded];
                                                  
                                              } completion:^(BOOL finished) {
                                                  
                                                  self.ufoAnimationCounter ++;
                                                  
                                                  [self animateUFO];
                                              }];
                         }];
    }
}

@end
