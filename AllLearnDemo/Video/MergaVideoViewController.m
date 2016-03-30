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
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    _firstAsset = nil;
    _secondAsset = nil;
    _audioAsset = nil;
    [_activityView stopAnimating];
}
- (IBAction)mergaTwoTrackAndSave:(id)sender {
    
    if (_firstAsset && _secondAsset) {
        [_activityView startAnimating];
        
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *firstTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:[[_firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        AVMutableCompositionTrack *secondTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _secondAsset.duration) ofTrack:[[_secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:_firstAsset.duration error:nil];
        
        
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
        
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(_firstAsset.duration, _secondAsset.duration));
        
        AVMutableVideoCompositionLayerInstruction *firstLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *firstAssetTrack = [[_firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation firstAssetOrientation = UIImageOrientationUp;
        BOOL isFirstAssetPartrait = NO;
        CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
        if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0) {
            firstAssetOrientation = UIImageOrientationRight;
            isFirstAssetPartrait = YES;
        }
        if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0) {
            firstAssetOrientation =  UIImageOrientationLeft;
            isFirstAssetPartrait = YES;
        }
        if (firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0) {
            firstAssetOrientation =  UIImageOrientationUp;
        }
        if (firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {
            firstAssetOrientation = UIImageOrientationDown;
        }
        NSLog(@"firstAssetTrack.naturalSize= %f, %f", firstAssetTrack.naturalSize.width, firstAssetTrack.naturalSize.height);//480 / 360
        CGFloat firstAssetScaleToFitRatio = [UIScreen mainScreen].bounds.size.width/firstAssetTrack.naturalSize.width;
        if(isFirstAssetPartrait){
            firstAssetScaleToFitRatio = [UIScreen mainScreen].bounds.size.width/firstAssetTrack.naturalSize.height;
            CGAffineTransform firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio,firstAssetScaleToFitRatio);
            [firstLayerInstruction setTransform:CGAffineTransformConcat(firstAssetTrack.preferredTransform, firstAssetScaleFactor) atTime:kCMTimeZero];
        }else{
            CGAffineTransform firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio,firstAssetScaleToFitRatio);
            [firstLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(firstAssetTrack.preferredTransform, firstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
        }
        [firstLayerInstruction setOpacity:0.0 atTime:_firstAsset.duration];
        
        
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        AVAssetTrack *secondAssetTrack = [[_secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation secondAssetOrientation  = UIImageOrientationUp;
        BOOL isSecondAssetPortrait  = NO;
        CGAffineTransform secondTransform = secondAssetTrack.preferredTransform;
        if (secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0) {
            secondAssetOrientation= UIImageOrientationRight;
            isSecondAssetPortrait = YES;
        }
        if (secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0) {
            secondAssetOrientation =  UIImageOrientationLeft;
            isSecondAssetPortrait = YES;
        }
        if (secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0) {
            secondAssetOrientation =  UIImageOrientationUp;
        }
        if (secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {
            secondAssetOrientation = UIImageOrientationDown;
        }
        NSLog(@"secondAssetTrack.naturalSize= %f, %f", secondAssetTrack.naturalSize.width, firstAssetTrack.naturalSize.height);//480 / 360
        CGFloat secondAssetScaleToFitRatio = [UIScreen mainScreen].bounds.size.width/secondAssetTrack.naturalSize.width;
        if(isSecondAssetPortrait){
            secondAssetScaleToFitRatio = [UIScreen mainScreen].bounds.size.width/secondAssetTrack.naturalSize.height;
            CGAffineTransform secondAssetScaleFactor = CGAffineTransformMakeScale(secondAssetScaleToFitRatio,secondAssetScaleToFitRatio);
            [secondlayerInstruction setTransform:CGAffineTransformConcat(secondAssetTrack.preferredTransform, secondAssetScaleFactor) atTime:_firstAsset.duration];
        }else{
            ;
            CGAffineTransform secondAssetScaleFactor = CGAffineTransformMakeScale(secondAssetScaleToFitRatio,secondAssetScaleToFitRatio);
            [secondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(secondAssetTrack.preferredTransform, secondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:_firstAsset.duration];
        }
        
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstLayerInstruction,secondlayerInstruction, nil];
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        
        CGSize naturalSizeFirst, naturalSizeSecond;
        if (isFirstAssetPartrait) {
            naturalSizeFirst = CGSizeMake(firstAssetTrack.naturalSize.height, firstAssetTrack.naturalSize.width);
        }else
        {
            naturalSizeFirst = firstAssetTrack.naturalSize;
        }
        
        if (isSecondAssetPortrait) {
            naturalSizeSecond = CGSizeMake(secondAssetTrack.naturalSize.height, secondAssetTrack.naturalSize.width);
        }else
        {
            naturalSizeSecond = secondAssetTrack.naturalSize;
        }
        
        float renderWidth, renderHeight;
        if (naturalSizeFirst.width > naturalSizeSecond.width) {
            renderWidth = naturalSizeFirst.width;
        }
        else
        {
            renderWidth = naturalSizeSecond.width;
        }
        
        if(naturalSizeFirst.height > naturalSizeSecond.height) {
            renderHeight = naturalSizeFirst.height;
        } else {
            renderHeight = naturalSizeSecond.height;
        }
        
        mainCompositionInst.renderSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, renderHeight);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergaVideo-%@.mov", [NSDate date]]];
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainCompositionInst;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
        
    }
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
