//
//  APODViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "APODViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Secrets.h"

@interface APODViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *APODImage;
@property (strong, nonatomic) NSString *APODdescriptionText;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) NSLayoutConstraint *descriptionTop;
@property (strong, nonatomic) NSLayoutConstraint *descriptionAfterAnimation;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rocketBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rocketAfterAnimation;

@end

@implementation APODViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;

}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.APODImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *APODurl = [NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?api_key=%@", APOD_API_KEY];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager GET:APODurl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //progress bar?
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *APODDictionary = responseObject;
        self.titleLabel.text = APODDictionary[@"title"];
        self.APODdescriptionText = APODDictionary[@"explanation"];
        
        NSURL *picURL = [NSURL URLWithString:APODDictionary[@"hdurl"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:picURL];
        
        [self.APODImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            CGFloat imageAspectRatio = image.size.width / image.size.height;
            [self.APODImage.widthAnchor constraintEqualToAnchor:self.APODImage.heightAnchor multiplier:imageAspectRatio].active = YES;
            self.APODImage.image = image;
            
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            
            //present an error message
            
        }];
        
        [self setUpDescriptionLabel];
        self.descriptionLabel.hidden = YES;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error");
        //present error message
        
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.APODImage;
}

#pragma - IBActions

- (IBAction)infoTapped:(id)sender
{
    self.infoButton.userInteractionEnabled = NO;
    [self prepareAudio];
    [self.audioPlayer play];
    
    [UIView animateWithDuration:51 animations:^{
        self.descriptionLabel.hidden = NO;
        self.titleLabel.hidden = YES;
        self.descriptionTop.active = NO;
        self.descriptionAfterAnimation.active = YES;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        self.titleLabel.hidden = NO;
        self.descriptionAfterAnimation.active = NO;
        self.descriptionTop.active = YES;
        self.descriptionLabel.hidden = YES;
        [self.view layoutIfNeeded];
        [self.audioPlayer stop];
        self.infoButton.userInteractionEnabled = YES;
        
    }];
}

- (IBAction)rocketTapped:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self performSegueWithIdentifier:@"segueToMars" sender:self];
}

 #pragma - View Set-Up

-(void)prepareAudio
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
}


-(void)setUpDescriptionLabel
{
    self.descriptionLabel = [[UILabel alloc]init];
    [self.view addSubview:self.descriptionLabel];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *descriptionCenter = [self.descriptionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
    descriptionCenter.active = YES;
    NSLayoutConstraint *descriptionWidth = [self.descriptionLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.9];
    descriptionWidth.active = YES;
    NSLayoutConstraint *descriptionHeight = [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor];
    descriptionHeight.active = YES;
    self.descriptionTop = [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.descriptionTop.active = YES;
    
    self.descriptionLabel.text = self.APODdescriptionText;
    self.descriptionLabel.textColor = [UIColor yellowColor];
    self.descriptionLabel.font = [UIFont fontWithName:@"Futura-Medium" size:18];
    self.descriptionLabel.numberOfLines = 50;
    
    self.descriptionAfterAnimation = [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.view.topAnchor];
    self.descriptionAfterAnimation.active = NO;
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
