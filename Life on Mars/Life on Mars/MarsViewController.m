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

@property (weak, nonatomic) IBOutlet UILabel *minFar;
@property (weak, nonatomic) IBOutlet UILabel *minCel;
@property (weak, nonatomic) IBOutlet UILabel *maxFar;
@property (weak, nonatomic) IBOutlet UILabel *maxCel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdated;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *sun;

@end

@implementation MarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //take center x
    //center y
    //width
    //height
    
    //        CGRect boundingRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height);
    
    CGRect boundingRect = CGRectMake(0, 0, 300, 300);
    
    CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
    orbit.keyPath = @"position";
    orbit.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
    orbit.duration = 8;
    orbit.additive = YES;
    orbit.repeatCount = HUGE_VALF;
    orbit.calculationMode = kCAAnimationPaced;
    orbit.rotationMode = kCAAnimationRotateAuto;
    
    [self.sun.layer addAnimation:orbit forKey:@"orbit"];
    
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
        
        self.minCel.text = [NSString stringWithFormat:@"Low: %@ °C", marsWeatherDictionary[@"min_temp"]];
        self.minFar.text = [NSString stringWithFormat:@"Low: %@ °F", marsWeatherDictionary[@"min_temp_fahrenheit"]];
        self.maxCel.text = [NSString stringWithFormat:@"High: %@ °C", marsWeatherDictionary[@"max_temp"]];
        self.maxFar.text = [NSString stringWithFormat:@"High: %@ °F", marsWeatherDictionary[@"max_temp_fahrenheit"]];
        self.weatherLabel.text = [NSString stringWithFormat:@"The weather on Mars is %@.", marsWeatherDictionary[@"atmo_opacity"]];
        self.lastUpdated.text = [NSString stringWithFormat:@"Last updated: %@", newDate];
        
        self.minCel.hidden = NO;
        self.minFar.hidden = NO;
        self.maxCel.hidden = NO;
        self.maxFar.hidden = NO;
        self.weatherLabel.hidden = NO;
        self.lastUpdated.hidden = NO;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error: %@", error.localizedDescription);
        //error message
        
    }];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)rocketTapped:(id)sender
{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 1.5;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionReveal;
//    transition.subtype = kCATransitionFromTop;
//    
//    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

 //-(void)animateSun
 //{
 //    [UIView animateWithDuration:1 animations:^{
 //        self.hiddenLeftConstraint.active = NO;
 //        self.animateRightConstraint.active = YES;
 //
 //        [self.view layoutIfNeeded];
 //
 //    } completion:^(BOOL finished) {
 //
 //        [self animateSun];
 //    }];
 //}

@end
