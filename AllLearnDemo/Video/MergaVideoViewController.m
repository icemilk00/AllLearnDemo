//
//  MergaVideoViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/3/28.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "MergaVideoViewController.h"

typedef enum {
    AVAssetSelectTypeFirstAsset = 0,
    AVAssetSelectTypeSecondAsset,
    AVAssetSelectTypeAudioAsset

}AVAssetSelectType;

#define ACTIVITY_HEIGHT_WIDTH (20.0f)


@interface MergaVideoViewController ()
{
    AVAssetSelectType currentAssetType;
}

@property (nonatomic, strong) AVAsset *firstAsset;
@property (nonatomic, strong) AVAsset *secondAsset;
@property (nonatomic, strong) AVAsset *audioAsset;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation MergaVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.activityView];
}


- (IBAction)loadFirstAsset:(id)sender {
    currentAssetType = AVAssetSelectTypeFirstAsset;
    [self selectMediaFromAlbum];
}

- (IBAction)loadSecondAsset:(id)sender {
    currentAssetType = AVAssetSelectTypeSecondAsset;
    [self selectMediaFromAlbum];
}

- (IBAction)loadAudio:(id)sender {
    currentAssetType = AVAssetSelectTypeAudioAsset;
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    [self presentViewController:mediaPicker animated:YES completion:nil];
    
}

- (IBAction)MergaVideoAndSave:(id)sender {
    
    if (_firstAsset && _secondAsset) {
        [_activityView startAnimating];
        
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *firstTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:[[_firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _secondAsset.duration) ofTrack:[[_secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:_firstAsset.duration error:nil];
        
        if (_audioAsset) {
            AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(_firstAsset.duration, _secondAsset.duration)) ofTrack:[[_audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        else
        {
            AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:[[_firstAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _secondAsset.duration) ofTrack:[[_secondAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:_firstAsset.duration error:nil];
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergaVideo-%@.mov", [NSDate date]]];
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
        
    }
}

-(void)exportDidFinish:(AVAssetExportSession *)exporter
{
    if (exporter.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputUrl = exporter.outputURL;
        ALAssetsLibrary *library= [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputUrl]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
    }
    
    _firstAsset = nil;
    _secondAsset = nil;
    _audioAsset = nil;
    [_activityView stopAnimating];
}

-(void)selectMediaFromAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        return;
    }
    
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    videoPicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    videoPicker.allowsEditing = YES;
    videoPicker.delegate = self;
    [self presentViewController:videoPicker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:picker completion:^{
        if (CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {

            if (currentAssetType == AVAssetSelectTypeFirstAsset) {
                
                self.firstAsset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else if (currentAssetType == AVAssetSelectTypeSecondAsset)
            {
                self.secondAsset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

#pragma mark - MediaPickerDelegate
-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSArray *selectSong = [mediaItemCollection items];
    if ([selectSong count] > 0) {
        MPMediaItem *songItem = selectSong[0];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        self.audioAsset = [AVAsset assetWithURL:songURL];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Audio Loaded"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setter and getter
-(UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - ACTIVITY_HEIGHT_WIDTH/2, CGRectGetMidY(self.view.frame) - ACTIVITY_HEIGHT_WIDTH/2, ACTIVITY_HEIGHT_WIDTH, ACTIVITY_HEIGHT_WIDTH)];
    }
    return _activityView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
