//
//  ViewController.m
//  PYAVFoundation
//
//  Created by wlpiaoyi on 14-10-22.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#include<AssetsLibrary/AssetsLibrary.h> 

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just videos.
        ALAssetsFilter *f = [ALAssetsFilter allVideos];
        [group setAssetsFilter:f];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            // The end of the enumeration is signaled by asset == nil
            if (result) {
                NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey :@YES };
                ALAssetRepresentation *representation = [result defaultRepresentation];
                NSURL *url = [representation url];
                AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:options];
                [avAsset loadValuesAsynchronouslyForKeys: @[@"duration"] completionHandler:^{
                    NSError *error = nil;
                    AVKeyValueStatus tracksStatus = [avAsset statusOfValueForKey:@"duration"
                                                                         error:&error];
                    switch (tracksStatus) {
                        case AVKeyValueStatusLoaded:{
                        }
                            break;
                        case AVKeyValueStatusFailed:
                            break;
                        case AVKeyValueStatusCancelled:
                        break;
                    }
                }];
                if ([[avAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
                    [self exportAsset:avAsset toFilePath:[NSString stringWithFormat:@"%@/a.mp4",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject]];
                    AVAssetImageGenerator *imageGenerator =
                    [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
                    // Implementation continues...
                    Float64 durationSeconds = CMTimeGetSeconds([avAsset duration]);
                    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
                    NSError *error;
                    CMTime actualTime;
                    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
                    UIImage *image = [UIImage imageWithCGImage:halfWayImage];
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                    NSArray *array = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
                    CGRect r = CGRectMake(0, 0, avAsset.naturalSize.width/20, avAsset.naturalSize.height/20);
                    imageview.frame = r;
                    [self.view addSubview:imageview];
                    
                    
                    if (halfWayImage != NULL) {
                        NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                        NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
                        NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString,
                              actualTimeString);
                        // Do something interesting with the image.
                        CGImageRelease(halfWayImage);
                    }
                }
            }
        }];
    } failureBlock:^(NSError *error) {
        
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath {
    
    BOOL b;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&b]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    // we need the audio asset to be at least 50 seconds long for this snippet
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
//    if (duration < 50.0) return NO;
    // get the first audio track
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0) return NO;
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    NSString *type = AVAssetExportPreset640x480;
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:type];
    if (nil == exportSession) return NO;
    
    // create trim time range - 20 seconds starting from 30 seconds into the asset
    CMTime startTime = CMTimeMake(4, 1);
    CMTime stopTime = CMTimeMake(6, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    // create fade in time range - 10 seconds starting at the beginning of trimmed asset
    CMTime startFadeInTime = startTime;
    CMTime endFadeInTime = CMTimeMake(5, 1);
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                            endFadeInTime);
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0
                                                      timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray
                                      arrayWithObject:exportAudioMixInputParameters];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeMPEG4; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
