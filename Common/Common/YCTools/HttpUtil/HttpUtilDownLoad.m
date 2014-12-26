//
//  HttpUtilDownLoad.m
//  Common
//
//  Created by wlpiaoyi on 14-10-18.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "HttpUtilDownLoad.h"
#import "Common.h"
#define CONFIGURATIONSESSIONBGSUFFIX @"org.piaoyi.backgroundsession"
static id synonceToken;

@interface HttpUtilDownLoad(){
@private
    CallBackHttpUtilDownLoaded callbackDownloaded;
    CallBackHttpUtilDownLoadResume callbackDownloadResume;
    CallBackHttpUtilDownLoaded callbackDownloadFailed;
    CallBackHttpUtilDowndLoadSuspend callbackDownloadSuspend;
    CallBackHttpUtilDowndLoadSuspend callbackDownloadCancel;
    
    NSURLSession *sessionBackground;
    NSURLSessionDownloadTask *downloadTask;
    
    unsigned long long int totalBytes;
    
    long currenttime;
    
    id syndelegate;
}
@end
@implementation HttpUtilDownLoad
@synthesize downLoadKey,downLoadString,userInfo,delegate;

+(void) initialize{
    synonceToken = [NSObject new];
}
-(id) init{
    if (self = [super init]) {
        syndelegate = [NSObject new];
    }
    return self;
}
-(void) setDownLoadedSuccessCallBack:(CallBackHttpUtilDownLoaded) callback{
    callbackDownloaded = callback;
}
-(void) setDownLoadedResumeDataCallBack:(CallBackHttpUtilDownLoadResume) callback{
    callbackDownloadResume = callback;
}
-(void) setDownLoadingFaildCallBack:(CallBackHttpUtilDownLoaded) callback{
    callbackDownloadFailed = callback;
}
-(void) setDownLoadingSuspendCallBack:(CallBackHttpUtilDowndLoadSuspend) callback{
    callbackDownloadSuspend = callback;
}
-(void) setDownLoadingCancelCallBack:(CallBackHttpUtilDowndLoadSuspend) callback{
    callbackDownloadCancel = callback;
}
-(void) setDelegate:(id<HttpUtilConnectionDataDelegate>)_delegate_{
    @synchronized(syndelegate){
        delegate = _delegate_;
        if (delegate) {
            if ([delegate respondsToSelector:@selector(connectionWait:)]) {
                [delegate connectionWait:self];
            }
        }
    }
}
-(BOOL) resumeDownLoad{
    @synchronized(synonceToken){
        if (!downloadTask) {
            sessionBackground = [self createSession];
            if (!sessionBackground) {
                return false;
            }
            if (![NSString isEnabled:downLoadString]) {
                return false;
            }
            NSData *resumedata;
            if (callbackDownloadResume) {
                resumedata = callbackDownloadResume(downLoadKey,userInfo);
            }
            downloadTask = [self createDownloadTask:sessionBackground DownLoadString:downLoadString Resumedata:resumedata];
            if (!downloadTask) {
                return false;
            }
        }
    }
    [downloadTask resume];
    currenttime = timeInterval();
    return true;
}
-(BOOL) suspendDownLoad{
    if (downloadTask) {
        switch (downloadTask.state) {
            case NSURLSessionTaskStateRunning:
            {
                [downloadTask suspend];
                @synchronized(syndelegate){
                    if (delegate) {
                        if ([delegate respondsToSelector:@selector(connectionWait:)]) {
                            [delegate connectionWait:self];
                        }
                    }
                }
            }
                return true;
            default:
                break;
        }
    }
    return false;
}
-(BOOL) cancelDownLoad{
    callbackDownloaded = nil;
    callbackDownloadResume = nil;
    callbackDownloadFailed = nil;
    downLoadKey = nil;
    downLoadString = nil;
    currenttime = 0;
    if (downloadTask) {
        [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (callbackDownloadCancel) {
                callbackDownloadCancel(resumeData,downLoadKey);
            }
        }];
    }
    downloadTask = nil;
    sessionBackground = nil;
    return true;
}


#pragma mark - NSURLSessionDownloadDelegate
//这个方法用来跟踪下载数据并且根据进度刷新ProgressView
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (!totalBytes) {
        totalBytes = totalBytesExpectedToWrite;
        
        @synchronized(syndelegate){
            if (delegate) {
                [delegate connection:totalBytes];
            }
        }
    }
    float pro =  (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    int persent = (unsigned int)(pro*100.0);
    
    @synchronized(syndelegate){
        if (delegate) {
            if ([delegate respondsToSelector:@selector(connectionDidReceiveData:)]) {
                [delegate connectionDidReceiveData:persent];
            }
        }
    }
}

//下载任务完成,这个方法在下载完成时触发，它包含了已经完成下载任务得 Session Task,Download Task和一个指向临时下载文件得文件路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *relativePath = [location relativePath];
    @try {
        if (callbackDownloaded) {
            callbackDownloaded(relativePath,downLoadKey,userInfo);
        }
        @synchronized(syndelegate){
            if (delegate) {
                [delegate connectionDidFinishLoaded:self Path:relativePath];
            }
        }
    }
    @finally {
        BOOL isDirectory;
        if ([Utils fileExistsAtPath:relativePath isDirectory:&isDirectory isCreated:false]&&!isDirectory) {
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtPath:relativePath error:&err];
            if (err) {
                NSLog(@"download delete err[code:%ld,description:%@]",(long)err.code,err.description);
            }
        }
    }
}

//从已经保存的数据中恢复下载任务的委托方法，fileOffset指定了恢复下载时的文件位移字节数：
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        if (callbackDownloadSuspend) {
            NSData *resumedata =  [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            callbackDownloadSuspend(resumedata,downLoadKey);
        }
        @synchronized(syndelegate){
            if (delegate) {
                [delegate connection:self didFailWithError:error];
            }
        }
    }
}
#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
}


-(NSURLSessionDownloadTask*) createDownloadTask:(NSURLSession*)session
                                 DownLoadString:(NSString*) downLoadstr
                                     Resumedata:(NSData*) resumedata{
    if (resumedata) {
        return [session downloadTaskWithResumeData:resumedata];
    }else{
        NSURL *URL = [NSURL URLWithString:downLoadstr];
        return [sessionBackground downloadTaskWithURL:URL];
    }
    
}
-(NSURLSession*) createSession{
    //这个sessionConfiguration 很重要， com.zyprosoft.xxx  这里，这个com.company.这个一定要和 bundle identifier 里面的一致，否则ApplicationDelegate 不会调用handleEventsForBackgroundURLSession代理方法
    NSURLSessionConfiguration *configuration;
    if ([systemVersion floatValue]>=8.0) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%lu",CONFIGURATIONSESSIONBGSUFFIX,(unsigned long)[self hash]]];
    }else{
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:[NSString stringWithFormat:@"%@%lu",CONFIGURATIONSESSIONBGSUFFIX,(unsigned long)[self hash]]];
    }
    configuration.URLCache =   [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024*1024 diskCapacity:100 * 1024*1024 diskPath:@"downloadcache"];
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

@end
