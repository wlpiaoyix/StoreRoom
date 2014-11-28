//
//  NetWorkRequest.h
//  Common
//
//  Created by wlpiaoyi on 14-10-7.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#define NetWorkOutTime 30

#import <Foundation/Foundation.h>


@protocol NetWorkConnectionDataDelegate;

//http请求反馈
typedef void (^CallBackNetWorkHTTP)(id data,NSDictionary* userInfo);
//下载请求完成时反馈
typedef void (^CallBackNetWorkDownLoaded)(NSString* relativePath ,NSString* downLoadKey ,NSDictionary* userInfo);
//下载请求恢复数据反馈
typedef NSData* (^CallBackNetWorkDownLoadResume)(NSString* downLoadKey ,NSDictionary* userInfo);
//下载请求暂停数据反馈
typedef void (^CallBackNetWorkDowndLoadSuspend)(NSData *resumeData ,NSString *downLoadKey);
typedef void (^CallBackNetWorkUpLoading)(NSDictionary* userInfo);
/**
 HTTP数据请求
 */
@protocol NetWorkHTTPDelegate <NSObject>
/**
 用户参数信息
 */
-(void) setUserInfo:(id) userInfo;
/**
 http编码方式
 */
-(void) setHttpEncoding:(NSStringEncoding) encoding;
/**
 http请求地址
 */
-(void) setRequestString:(NSString*) requestString;
/**
 添加头信息
 */
-(void) addRequestHeadValue:(NSDictionary*) dic;
-(void) requestPOST:(NSDictionary*) params;
-(void) requestPUT:(NSDictionary*) params;
-(void) requestGET:(NSDictionary*) params;
-(void) requestDELETE:(NSDictionary*) params;
-(void) requestPOST:(NSDictionary*) params OutTime:(int) outTime;
-(void) requestPUT:(NSDictionary*) params OutTime:(int) outTime;
-(void) requestGET:(NSDictionary*) params OutTime:(int) outTime;
-(void) requestDELETE:(NSDictionary*) params OutTime:(int) outTime;
//-(void) startAsynRequest;
/**
 http请求成功后的反馈
 */
-(void) setSuccessCallBack:(CallBackNetWorkHTTP) callback;
/**
 http请求失败后的反馈
 */
-(void) setFaildCallBack:(CallBackNetWorkHTTP) callback;
-(void) cancel;
//@optional
//-(void) startSynRequest;
@end
/**
 数据下载
 */
@protocol NetWorkDownLoadDelegate <NSObject>
//下载地址
@property (nonatomic,strong) NSString* downLoadString;
//特殊用途的标示符
@property (nonatomic,strong) NSString* downLoadKey;
//用户数据
@property (nonatomic,strong) id userInfo;
@property (nonatomic,assign) id<NetWorkConnectionDataDelegate> delegate;
-(void) setDownLoadedSuccessCallBack:(CallBackNetWorkDownLoaded) callback;
-(void) setDownLoadingFaildCallBack:(CallBackNetWorkDownLoaded) callback;
-(void) setDownLoadingSuspendCallBack:(CallBackNetWorkDowndLoadSuspend) callback;
-(void) setDownLoadingCancelCallBack:(CallBackNetWorkDowndLoadSuspend) callback;
-(void) setDownLoadedResumeDataCallBack:(CallBackNetWorkDownLoadResume) callback;
-(BOOL) resumeDownLoad;
-(BOOL) suspendDownLoad;
-(BOOL) cancelDownLoad;
@end
/**
 数据上传
 */
@protocol NetWorkUpLoadDelegate <NSObject>
-(void) setUpLoadString:(NSString*) upLoadString;
-(void) setUpLoadingSuccessCallBack:(CallBackNetWorkUpLoading) callback;
-(void) setUpLoadingFaildCallBack:(CallBackNetWorkUpLoading) callback;
-(void) resumeUpLoad;
-(void) suspendUpLoad;
-(void) cancelUpLoad;
@end
/**
 数据连接协议
 */
@protocol NetWorkConnectionDataDelegate <NSObject>
@required
-(void)connection:(unsigned long long int) totalBytes;
-(void)connection:(id)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoaded:(id)connection Path:(NSString*) path;
@optional
-(void)connectionDidReceiveData:(int) persent;
-(void)connectionDidSendData:(int) persent;
-(void)connectionWait:(id)connection;
@end
