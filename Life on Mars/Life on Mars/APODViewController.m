//
//  APODViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "APODViewController.h"
#import "Secrets.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface APODViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *APODImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *spaceshipButton;
@property (strong, nonatomic) IBOutlet UIButton *marsButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIStackView *buttonStackView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonStackRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rocketAfterAnimation;
@property (strong, nonatomic) NSLayoutConstraint *descriptionTop;
@property (strong, nonatomic) NSLayoutConstraint *descriptionAfterAnimation;
@property (strong, nonatomic) NSLayoutConstraint *buttonPreAnimation;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *APODdescriptionText;

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
     self.buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
     
     self.buttonStackRightConstraint.active = NO;
     self.buttonPreAnimation = [self.buttonStackView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:100];
     self.buttonPreAnimation.active = YES;
    
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
- (IBAction)spaceshipTapped:(id)sender
{
     [self prepareSpaceshipAudio];
     [self.audioPlayer play];
     if (self.buttonPreAnimation.active) {
          [UIView animateWithDuration:1 animations:^{
               self.buttonPreAnimation.active = NO;
               self.buttonStackRightConstraint.active = YES;
               
               [self.view layoutIfNeeded];
               
          } completion:^(BOOL finished) {
               //
          }];
     } else {
          [UIView animateWithDuration:1 animations:^{
               self.buttonStackRightConstraint.active = NO;
               self.buttonPreAnimation.active = YES;
               
               [self.view layoutIfNeeded];
               
          } completion:^(BOOL finished) {
               //
          }];
     }
     
}

- (IBAction)infoTapped:(id)sender
{
    self.infoButton.userInteractionEnabled = NO;
     self.spaceshipButton.userInteractionEnabled = NO;
     self.infoButton.hidden = YES;
     self.spaceshipButton.hidden = YES;
     self.marsButton.hidden = YES;
     self.saveButton.hidden = YES;
     
    [self prepareScrollAudio];
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
         self.spaceshipButton.userInteractionEnabled = YES;
         self.infoButton.hidden = NO;
         self.spaceshipButton.hidden = NO;
         self.marsButton.hidden = NO;
         self.saveButton.hidden = NO;
    }];
}

-(IBAction)saveTapped:(id)sender
{
     NSData *imageData = UIImageJPEGRepresentation(self.APODImage.image, 1);
     UIImage *compressedJPGImage = [UIImage imageWithData:imageData];
     UIImageWriteToSavedPhotosAlbum(compressedJPGImage, self, @selector(saveImageHandler:didFinishSavingWithError:contextInfo:), nil);
}

-(void)saveImageHandler:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
     if (error) {
          UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"OH NO!" message:[NSString stringWithFormat:@"There was an error saving the image: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               //
          }];
          
          [errorAlert addAction:errorAction];
          
          [self presentViewController:errorAlert animated:YES completion:nil];
     } else {
          
          UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"Saved!" message:[NSString stringWithFormat:@"%@ is now in your Photos!", self.titleLabel.text] preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               //
          }];
          
          [saveAlert addAction:okAction];
          
          [self presentViewController:saveAlert animated:YES completion:nil];
     }
}

 #pragma - Set-Up

-(void)prepareScrollAudio
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
}

-(void)prepareSpaceshipAudio
{
     NSURL *url = [[NSBundle mainBundle] URLForResource:@"ray" withExtension:@"mp3"];
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
    NSLayoutConstraint *descriptionHeight = [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.75];
    descriptionHeight.active = YES;
    self.descriptionTop = [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.descriptionTop.active = YES;
    
    self.descriptionLabel.text = self.APODdescriptionText;
     self.descriptionLabel.textColor = [UIColor whiteColor];
     self.descriptionLabel.font = [UIFont fontWithName:@"Futura-Medium" size:18];
     self.descriptionLabel.numberOfLines = 25;
     self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    
    self.descriptionAfterAnimation = [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.view.topAnchor];
    self.descriptionAfterAnimation.active = NO;
}

@end
