//
//  APODViewController.m
//  Life on Mars
//
//  Created by Jeremy Feld on 5/2/16.
//  Copyright © 2016 JBF. All rights reserved.
//

#import "APODViewController.h"
#import "JBFConstants.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SafariServices/SafariServices.h>

@interface APODViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *APODImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *spaceshipButton;
@property (weak, nonatomic) IBOutlet UIButton *marsButton;
@property (weak, nonatomic) IBOutlet UIButton *earthButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) BOOL buttonStackShowing;

@end

@implementation APODViewController

- (void)viewDidLoad
{
     [super viewDidLoad];
     
     self.scrollView.delegate = self;
     self.buttonStackShowing = NO;
     
     if (!self.APODImageView.image) {
          
          [self fetchAPOD];
     }
}

- (BOOL)prefersStatusBarHidden
{
     return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
     return self.APODImageView;
}

#pragma - Actions
- (IBAction)spaceshipTapped:(id)sender
{
     [self playAudio:@"powerup"];
     
     if (!self.buttonStackShowing) {
          
          [UIView animateWithDuration:0.4 animations:^{
               
               CGAffineTransform transform = CGAffineTransformIdentity;
               
               transform = CGAffineTransformTranslate(transform, -216, 0);
               
               self.buttonStackView.transform = transform;
               
               self.buttonStackShowing = YES;
          }];
          
     } else {
          
          [UIView animateWithDuration:0.4 animations:^{
               
               self.buttonStackView.transform = CGAffineTransformIdentity;
               self.buttonStackShowing = NO;
          }];
     }
}

- (IBAction)earthButtonTapped:(id)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)infoTapped:(id)sender
{
     self.infoButton.userInteractionEnabled = NO;
     self.spaceshipButton.userInteractionEnabled = NO;
     self.infoButton.hidden = YES;
     self.spaceshipButton.hidden = YES;
     self.marsButton.hidden = YES;
     self.saveButton.hidden = YES;
     self.earthButton.hidden = YES;
     
     [self playAudio:@"music"];
     
     [UIView animateWithDuration:51 animations:^{
          
          self.titleLabel.hidden = YES;
          CGAffineTransform transform = CGAffineTransformIdentity;
          
          transform = CGAffineTransformTranslate(transform, 0, -(self.view.frame.size.height + self.descriptionLabel.frame.size.height));
          
          self.descriptionLabel.transform = transform;
          
     } completion:^(BOOL finished) {
          
          self.titleLabel.hidden = NO;
          self.descriptionLabel.transform = CGAffineTransformIdentity;
          [self.audioPlayer stop];
          
          self.infoButton.userInteractionEnabled = YES;
          self.spaceshipButton.userInteractionEnabled = YES;
          self.infoButton.hidden = NO;
          self.spaceshipButton.hidden = NO;
          self.marsButton.hidden = NO;
          self.saveButton.hidden = NO;
          self.earthButton.hidden = NO;
     }];
}

- (IBAction)saveTapped:(id)sender
{
     NSData *imageData = UIImageJPEGRepresentation(self.APODImageView.image, 1);
     UIImage *compressedJPGImage = [UIImage imageWithData:imageData];
     UIImageWriteToSavedPhotosAlbum(compressedJPGImage, self, @selector(saveImageHandler:didFinishSavingWithError:contextInfo:), nil);
}

#pragma - Audio & Video

- (void)playAudio:(NSString *)soundName
{
     NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:@"mp3"];
     self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
     [self.audioPlayer prepareToPlay];
     [self.audioPlayer play];
}

- (void)handleVideoFromDictionary:(NSDictionary *)APODDictionary
{
     NSURL *youtubeURL = [NSURL URLWithString:APODDictionary[@"url"]];
     SFSafariViewController *youtubeView = [[SFSafariViewController alloc] initWithURL:youtubeURL];
     [self presentViewController:youtubeView animated:YES completion:nil];
}

#pragma mark - Alert Methods

- (void)saveImageHandler:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
     if (error) {
          
          UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:[NSString stringWithFormat:@"There was an error saving the image: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
          
          UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          }];
          
          [errorAlert addAction:errorAction];
          
          [self presentViewController:errorAlert animated:YES completion:nil];
          
     } else {
          
          UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@ is now saved in your Photos!", self.titleLabel.text] preferredStyle:UIAlertControllerStyleAlert];
          
          UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          }];
          
          [saveAlert addAction:okAction];
          
          [self presentViewController:saveAlert animated:YES completion:nil];
     }
}

- (void)displayErrorAlert:(NSError *)error
{
     UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:[NSString stringWithFormat:@"There was an error loading the data: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     }];
     
     [errorAlert addAction:dismissAction];
     
     [self presentViewController:errorAlert animated:YES completion:nil];
}

#pragma mark - API

-(void)fetchAPOD
{
     NSString *APODurl = [NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?api_key=%@", APOD_API_KEY];
     
     AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
     [sessionManager GET:APODurl parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
          
          NSDictionary *APODDictionary = responseObject;
          self.titleLabel.text = APODDictionary[@"title"];
          self.descriptionLabel.text = APODDictionary[@"explanation"];;
          
          if ([APODDictionary[@"media_type"] isEqualToString:@"video"]) {
               
               [self handleVideoFromDictionary:APODDictionary];
               
          } else {
               
               NSURL *picURL = [NSURL URLWithString:APODDictionary[@"hdurl"]];
               NSURLRequest *request = [NSURLRequest requestWithURL:picURL];
               
               [self.APODImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    
                    CGFloat imageAspectRatio = image.size.width / image.size.height;
                    
                    [self.APODImageView.widthAnchor constraintEqualToAnchor:self.APODImageView.heightAnchor multiplier:imageAspectRatio].active = YES;
                    
                    self.APODImageView.image = image;
                    
               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                    [self displayErrorAlert:error];
               }];
          }
          
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
          
          [self displayErrorAlert:error];
     }];
}

@end
