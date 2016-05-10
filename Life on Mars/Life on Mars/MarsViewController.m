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
@property (strong, nonatomic) IBOutlet UIImageView *martianImageView;

@end

@implementation MarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self animateMartian];
    [self animateSun];
    
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
    
    [UIView animateWithDuration:1 delay:3 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.martianImageView.transform = CGAffineTransformMakeTranslation(0, -transformationY);
        
        [self.martianImageView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.martianImageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
            [self animateMartian];
        }];
    }];
}

//take center x
//center y
//width
//height

-(void)animateSun
{
    CGFloat xPoint = self.view.frame.size.width;
    CGFloat yPoint = self.view.frame.size.height/2;
    CGRect boundingRect = CGRectMake(-xPoint, 0, self.view.frame.size.width*3, self.view.frame.size.height*1.25);
    
    CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
    orbit.keyPath = @"position";
    orbit.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
    orbit.duration = 20;
    orbit.additive = YES;
    orbit.repeatCount = HUGE_VALF;
    orbit.calculationMode = kCAAnimationPaced;
    orbit.rotationMode = kCAAnimationRotateAuto;
    
    [self.sun.layer addAnimation:orbit forKey:@"orbit"];
}

@end
