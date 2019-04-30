#import "RNVideoEditor.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <UIKit/UIKit.h>

@implementation RNVideoEditor

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(merge:(NSArray *)fileNames
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {
    
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self MergeVideo:fileNames callback:successCallback];
    //successCallback(@[@"merge video", fileNames[0]]);
}

RCT_EXPORT_METHOD(trim:(NSString *)fileName start:(double) start end:(double) end
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self TrimVideo:fileName start:start end:end callback:successCallback];
}

RCT_EXPORT_METHOD(getthumbnails:(NSString *)fileName
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self GetThumbnails:fileName callback:successCallback];
}
-(void)GetThumbnails:(NSString *)fileName callback:(RCTResponseSenderBlock)successCallback
{
    NSURL* url = [NSURL URLWithString:fileName];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    
    CMTime duration = [asset duration];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(0, duration.timescale);
    CMTime time2 = CMTimeMake((duration.value / 5)*1, duration.timescale);
    CMTime time3 = CMTimeMake((duration.value / 5)*2, duration.timescale);
    CMTime time4 = CMTimeMake((duration.value / 5)*3, duration.timescale);
    CMTime time5 = CMTimeMake((duration.value / 5)*4, duration.timescale);
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    CGImageRef imageRef2 = [imageGenerator copyCGImageAtTime:time2 actualTime:NULL error:NULL];
    CGImageRef imageRef3 = [imageGenerator copyCGImageAtTime:time3 actualTime:NULL error:NULL];
    CGImageRef imageRef4 = [imageGenerator copyCGImageAtTime:time4 actualTime:NULL error:NULL];
    CGImageRef imageRef5 = [imageGenerator copyCGImageAtTime:time5 actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    UIImage *thumbnail2 = [UIImage imageWithCGImage:imageRef2];
    UIImage *thumbnail3 = [UIImage imageWithCGImage:imageRef3];
    UIImage *thumbnail4 = [UIImage imageWithCGImage:imageRef4];
    UIImage *thumbnail5 = [UIImage imageWithCGImage:imageRef5];
    NSString* tempDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                   NSUserDomainMask,
                                                                   YES) lastObject];
    
    NSData *data = UIImageJPEGRepresentation(thumbnail, 1.0);
    NSData *data2 = UIImageJPEGRepresentation(thumbnail2, 1.0);
    NSData *data3 = UIImageJPEGRepresentation(thumbnail3, 1.0);
    NSData *data4 = UIImageJPEGRepresentation(thumbnail4, 1.0);
    NSData *data5 = UIImageJPEGRepresentation(thumbnail5, 1.0);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
    NSString *fullPath2 = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
    NSString *fullPath3 = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
    NSString *fullPath4 = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
    NSString *fullPath5 = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
    
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    [fileManager createFileAtPath:fullPath2 contents:data2 attributes:nil];
    [fileManager createFileAtPath:fullPath3 contents:data3 attributes:nil];
    [fileManager createFileAtPath:fullPath4 contents:data4 attributes:nil];
    [fileManager createFileAtPath:fullPath5 contents:data5 attributes:nil];
    
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    CGImageRelease(imageRef2);  // CGImageRef won't be released by ARC
    CGImageRelease(imageRef3);  // CGImageRef won't be released by ARC
    CGImageRelease(imageRef4);  // CGImageRef won't be released by ARC
    CGImageRelease(imageRef5);  // CGImageRef won't be released by ARC
    
    successCallback(@[@"merge video complete",fullPath,fullPath2,fullPath3,fullPath4,fullPath5]);
    
    
    
    
}
-(void)TrimVideo:(NSString *)fileName start:(double)start end:(double )end callback:(RCTResponseSenderBlock)successCallback
{
    NSURL* url = [NSURL URLWithString:fileName];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    if([[NSFileManager defaultManager] fileExistsAtPath:outputURL])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outputURL error:nil];
    }
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTime startT = CMTimeMakeWithSeconds(start, 600); // you will modify time range here
    CMTime durationT = CMTimeMakeWithSeconds((end-start), 600);
    CMTimeRange range = CMTimeRangeMake(startT, durationT);
    exportSession.timeRange = range;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:
                 successCallback(@[@"merge video complete",outputURL]);
                 
                 //                 [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                 //                 NSLog(@"Export Complete %d %@", exportSession.status, exportSession.error);
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 break;
                 
             default:
                 break;
         }
     }];
    
}
-(void)LoopVideo:(NSArray *)fileNames callback:(RCTResponseSenderBlock)successCallback
{
    for (id object in fileNames)
    {
        NSLog(@"video: %@", object);
    }
}

-(void)MergeVideo:(NSArray *)fileNames callback:(RCTResponseSenderBlock)successCallback
{
    
    CGFloat totalDuration;
    totalDuration = 0;
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime insertTime = kCMTimeZero;
    CGAffineTransform originalTransform;
    
    for (id object in fileNames)
    {
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:object]];
        
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        [videoTrack insertTimeRange:timeRange
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:insertTime
                              error:nil];
        
        [audioTrack insertTimeRange:timeRange
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:insertTime
                              error:nil];
        
        insertTime = CMTimeAdd(insertTime,asset.duration);
        
        // Get the first track from the asset and its transform.
        NSArray* tracks = [asset tracks];
        AVAssetTrack* track = [tracks objectAtIndex:0];
        originalTransform = [track preferredTransform];
    }
    
    // Use the transform from the original track to set the video track transform.
    if (originalTransform.a || originalTransform.b || originalTransform.c || originalTransform.d) {
        videoTrack.preferredTransform = originalTransform;
    }
    
    NSString* documentsDirectory= [self applicationDocumentsDirectory];
    NSString * myDocumentPath = [documentsDirectory stringByAppendingPathComponent:@"merged_video.mp4"];
    NSURL * urlVideoMain = [[NSURL alloc] initFileURLWithPath: myDocumentPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myDocumentPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myDocumentPath error:nil];
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = urlVideoMain;
    exporter.outputFileType = @"com.apple.quicktime-movie";
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exporter status])
        {
            case AVAssetExportSessionStatusFailed:
                break;
                
            case AVAssetExportSessionStatusCancelled:
                break;
                
            case AVAssetExportSessionStatusCompleted:
                successCallback(@[@"merge video complete", myDocumentPath]);
                break;
                
            default:
                break;
        }
    }];
}

- (NSString*) applicationDocumentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end

