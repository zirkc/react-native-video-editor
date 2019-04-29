
#import "RNVideoEditor.h"
//Zirk2

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
    
    //    [self TrimVideo:fileName start:start end:end endcallback:successCallback];
    [self TrimVideo:fileName start:start end:end callback:successCallback];
    
    //successCallback(@[@"merge video", fileNames[0]]);
}

-(void)TrimVideo:(NSString *)fileName start:(double)start end:(double )end callback:(RCTResponseSenderBlock)successCallback
{
    NSURL* url = [NSURL URLWithString:fileName];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
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
    
    //[exportS
    /*
     
     
     CGFloat totalDuration;
     totalDuration = 0;
     
     AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
     
     AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
     preferredTrackID:kCMPersistentTrackID_Invalid];
     
     AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
     preferredTrackID:kCMPersistentTrackID_Invalid];
     
     CMTime insertTime = kCMTimeZero;
     CGAffineTransform originalTransform;
     
     AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:fileName]];
     
     CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
     
     [videoTrack insertTimeRange:timeRange
     ofTrack:[asset tracksWithMediaType:AVMediaTypeVideo]
     atTime:insertTime
     error:nil];
     
     [audioTrack insertTimeRange:timeRange
     ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio]
     atTime:insertTime
     error:nil];
     
     insertTime = CMTimeAdd(insertTime,asset.duration);
     
     // Get the first track from the asset and its transform.
     NSArray* tracks = [asset tracks];
     AVAssetTrack* track = [tracks objectAtIndex:0];
     originalTransform = [track preferredTransform];
     
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
     */
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

