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
#import <SafariServices/SafariServices.h>

@interface APODViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *APODImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *spaceshipButton;
@property (weak, nonatomic) IBOutlet UIButton *marsButton;
@property (weak, nonatomic) IBOutlet UIButton *earthButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonStackRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descriptionTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descriptionAfterAnimationConstraint;
@property (strong, nonatomic) NSLayoutConstraint *buttonPreAnimationConstraint;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *APODdescriptionText;

@end

@implementation APODViewController

- (void)viewDidLoad
{
     [super viewDidLoad];
     
     self.scrollView.delegate = self;
     
     self.buttonStackRightConstraint.active = NO;
     self.buttonPreAnimationConstraint = [self.buttonStackView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:100];
     self.buttonPreAnimationConstraint.active = YES;
}

- (BOOL)prefersStatusBarHidden
{
     return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
     [super viewDidAppear:YES];
     
     NSString *APODurl = [NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?api_key=%@", APOD_API_KEY];
     
     AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
     [sessionManager GET:APODurl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
          
          //progress bar?
          
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          NSDictionary *APODDictionary = responseObject;
          self.titleLabel.text = APODDictionary[@"title"];
          self.APODdescriptionText = APODDictionary[@"explanation"];
          
          if ([APODDictionary[@"media_type"] isEqualToString:@"video"]) {
               
               [self handleVideoFromDictionary:APODDictionary];
               
          } else {
               
               NSURL *picURL = [NSURL URLWithString:APODDictionary[@"hdurl"]];
               NSURLRequest *request = [NSURLRequest requestWithURL:picURL];
               
               [self.APODImageView setImageWithURLRequest:request
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                       
                                                       CGFloat imageAspectRatio = image.size.width / image.size.height;
                                                       
                                                       [self.APODImageView.widthAnchor constraintEqualToAnchor:self.APODImageView.heightAnchor multiplier:imageAspectRatio].active = YES;
                                                       
                                                       self.APODImageView.image = image;
                                                       
                                                  } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                       
                                                       [self displayErrorAlert:error];
                                                  }];
          }
          
          [self setUpDescriptionLabel];
          self.descriptionLabel.hidden = YES;
          
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          
          [self displayErrorAlert:error];
     }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
     return self.APODImageView;
}

#pragma - IBActions
- (IBAction)spaceshipTapped:(id)sender
{
     [self prepareAudio:@"ray"];
     [self.audioPlayer play];
     
     if (self.buttonPreAnimationConstraint.active) {
          
          [UIView animateWithDuration:1 animations:^{
               
               self.buttonPreAnimationConstraint.active = NO;
               self.buttonStackRightConstraint.active = YES;
               
               [self.view layoutIfNeeded];
               
          } completion:nil];
          
     } else {
          
          [UIView animateWithDuration:1 animations:^{
               
               self.buttonStackRightConstraint.active = NO;
               self.buttonPreAnimationConstraint.active = YES;
               
               [self.view layoutIfNeeded];
               
          } completion:nil];
     }
}

- (IBAction)earthButtonTapped:(id)sender
{
     CATransition *transition = [CATransition animation];
     transition.duration = .8;
     transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
     transition.type = kCATransitionFade;
     transition.subtype = kCATransitionFromTop;
     
     [self.view.window.layer addAnimation:transition forKey:nil];
     [self performSegueWithIdentifier:@"segueToEarth" sender:self];
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
     
     [self prepareAudio:@"intro"];
     [self.audioPlayer play];
     
     [UIView animateWithDuration:51 animations:^{
          
          self.descriptionLabel.hidden = NO;
          self.titleLabel.hidden = YES;
          self.descriptionTopConstraint.active = NO;
          self.descriptionAfterAnimationConstraint.active = YES;
          
          [self.view layoutIfNeeded];
          
     } completion:^(BOOL finished) {
          
          self.titleLabel.hidden = NO;
          self.descriptionAfterAnimationConstraint.active = NO;
          self.descriptionTopConstraint.active = YES;
          self.descriptionLabel.hidden = YES;
          
          [self.view layoutIfNeeded];
          
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

#pragma - Set-Up

- (void)prepareAudio:(NSString *)soundName
{
     NSDataAsset *soundAsset = [[NSDataAsset alloc] initWithName:soundName];
     self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundAsset.data error:nil];
     [self.audioPlayer prepareToPlay];
}

- (void)setUpDescriptionLabel
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
     
     self.descriptionTopConstraint = [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.view.bottomAnchor];
     self.descriptionTopConstraint.active = YES;
     
     self.descriptionLabel.text = self.APODdescriptionText;
     self.descriptionLabel.textColor = [UIColor whiteColor];
     self.descriptionLabel.font = [UIFont fontWithName:@"Futura-Medium" size:18];
     self.descriptionLabel.numberOfLines = 25;
     self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
     
     self.descriptionAfterAnimationConstraint = [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.view.topAnchor];
     self.descriptionAfterAnimationConstraint.active = NO;
}

#pragma mark - Alert Methods

- (void)saveImageHandler:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
     if (error) {
          
          UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:[NSString stringWithFormat:@"There was an error saving the image: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
          
          UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          }];
          
          [errorAlert addAction:errorAction];
          
          [self presentViewController:errorAlert animated:YES completion:nil];
          
     } else {
          
          UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"Saved!" message:[NSString stringWithFormat:@"%@ is now in your Photos!", self.titleLabel.text] preferredStyle:UIAlertControllerStyleAlert];
          
          UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          }];
          
          [saveAlert addAction:okAction];
          
          [self presentViewController:saveAlert animated:YES completion:nil];
     }
}

- (void)handleVideoFromDictionary:(NSDictionary *)APODDictionary
{
     UIAlertController *videoAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:@"The picture of the day is actually a video. Would you like to watch it?" preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     }];
     
     UIAlertAction *watchAction = [UIAlertAction actionWithTitle:@"Of Course!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          
          NSURL *youtubeURL = [NSURL URLWithString:APODDictionary[@"url"]];
          
          SFSafariViewController *youtubeView = [[SFSafariViewController alloc] initWithURL:youtubeURL];
          [self presentViewController:youtubeView animated:YES completion:nil];
     }];
     
     [videoAlert addAction:noAction];
     [videoAlert addAction:watchAction];
     
     [self presentViewController:videoAlert animated:YES completion:nil];
}

- (void)displayErrorAlert:(NSError *)error
{
     UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Houston, we have a problem!" message:[NSString stringWithFormat:@"There was an error loading the data: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"🚀👾 OK 👾🚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     }];
     
     [errorAlert addAction:dismissAction];
     
     [self presentViewController:errorAlert animated:YES completion:nil];
}

@end
