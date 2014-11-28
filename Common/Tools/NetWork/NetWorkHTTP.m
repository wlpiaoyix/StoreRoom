//
//  NetWorkRequest.m
//  Common
//
//  Created by wlpiaoyi on 14-10-7.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "NetWorkHTTP.h"
//==>传输方法
#define GET @"GET"
#define POST @"POST"
#define PUT @"PUT"
#define DELETE @"DELETE"
//<==
@interface NetWorkHTTP(){
@private
    CallBackNetWorkHTTP callBackSuccess;
    CallBackNetWorkHTTP callBackFaild;
}
@property (nonatomic) NSStringEncoding encoding;
@property (nonatomic,strong,readonly) id userInfo;
@property (nonatomic,strong,readonly) NSString *requestString;
@property (nonatomic,strong,readonly) NSMutableDictionary *httpHeaderFields;
@property (nonatomic,strong,readonly) NSMutableURLRequest	*request;
@property (nonatomic,strong,readonly) NSURLConnection	*connection;
@property (nonatomic,strong) NSMutableData *data;
@end

@implementation NetWorkHTTP
-(id) init{
    if (self=[super init]) {
        self.encoding = NSUTF8StringEncoding;
        _httpHeaderFields = [NSMutableDictionary new];
    }
    return self;
}
-(void) setUserInfo:(id) userInfo{
    _userInfo = userInfo;
}
-(void) setHttpEncoding:(NSStringEncoding) encoding{
    _encoding = encoding;
}
-(void) setRequestString:(NSString*) requestString{
    _requestString= requestString;
}
-(void) setSuccessCallBack:(CallBackNetWorkHTTP) callback{
    callBackSuccess = callback;
}
-(void) setFaildCallBack:(CallBackNetWorkHTTP) callback{
    callBackFaild = callback;
}
-(void) addRequestHeadValue:(NSDictionary*) dic{
    [_httpHeaderFields setValuesForKeysWithDictionary:dic];
}
-(void) requestPOST:(NSDictionary*) params{
    [self requestPOST:params OutTime:NetWorkOutTime];
}
-(void) requestPUT:(NSDictionary*) params{
    [self requestPUT:params OutTime:NetWorkOutTime];
}
-(void) requestGET:(NSDictionary*) params{
    [self requestGET:params OutTime:NetWorkOutTime];
}
-(void) requestDELETE:(NSDictionary*) params{
    [self requestDELETE:params OutTime:NetWorkOutTime];
}
-(void) requestPOST:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createDataRequest:params OutTime:outTime];
    [_request setHTTPMethod:POST];
}
-(void) requestPUT:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createDataRequest:params OutTime:outTime];
    [_request setHTTPMethod:PUT];
}
-(void) requestGET:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createUrlRequest:params OutTime:outTime];
    [_request setHTTPMethod:GET];
}
-(void) requestDELETE:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createUrlRequest:params OutTime:outTime];
    [_request setHTTPMethod:DELETE];
}
-(NSString*) parseDicParamsToStringParams:(NSDictionary*) dicParam{
    if (!dicParam) {
        return nil;
    }
    NSString *stringParams = @"";
    for (NSString *key in [dicParam allKeys]) {
        id value = [dicParam objectForKey:key];
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                stringParams = [NSString stringWithFormat:@"%@&%@=%@",stringParams,key,value];
            }else if([value isKindOfClass:[NSNumber class]]){
                stringParams = [NSString stringWithFormat:@"%@&%@=%f",stringParams,key,[((NSNumber*)value) doubleValue]];
            }else if([value isKindOfClass:[NSData class]]){
                stringParams = [NSString stringWithFormat:@"%@&%@=%@",stringParams,key,[[NSString alloc] initWithData:value encoding:self.encoding]];
            }
        }
    }
    if (stringParams.length) {
        stringParams = [stringParams substringFromIndex:1];
    }
    return stringParams;
}
-(NSMutableURLRequest*) createUrlRequest:(NSDictionary*) params OutTime:(int) outTime{
//    params = nil;
    NSString *temp = params?[NSString stringWithFormat:@"%@?%@",_requestString,[self parseDicParamsToStringParams:params]]:_requestString;
    temp = [temp stringByAddingPercentEscapesUsingEncoding:self.encoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: temp] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:outTime];
    if (self.httpHeaderFields) {
        [self addAllHttpHeaderFields:self.httpHeaderFields Request:request];
    }
    return request;
}
-(NSMutableURLRequest*) createDataRequest:(NSDictionary*) params OutTime:(int) outTime{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_requestString]  cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:outTime];
    if (params) {
        NSData *postData = [[self parseDicParamsToStringParams:params] dataUsingEncoding:self.encoding  allowLossyConversion:YES];
        [request setHTTPBody:postData];
        NSString *postLength = [NSString stringWithFormat:@"%lli", (long long int)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    }
    if (self.httpHeaderFields) {
        if (self.httpHeaderFields) {
            [self addAllHttpHeaderFields:self.httpHeaderFields Request:request];
        }
    }
    return request;
}
-(void) addAllHttpHeaderFields:(NSDictionary*) dic Request:(NSMutableURLRequest*) request{
    for (NSString *key in [dic allKeys]) {
        [request setValue:[dic objectForKey:key] forHTTPHeaderField:key];
    }
}
-(void) startAsynRequest{
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    _data = [NSMutableData new];
    [_connection start];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

}
-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    [_data appendData:incrementalData];
}
-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    if (callBackFaild) {
        id userInfo = self.userInfo;
        callBackFaild([NSString stringWithFormat:@"code:%ld,description:%@",(long)[error code],error.description],userInfo);
    }
    [self cancel];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{

}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    if (callBackSuccess) {
        NSString *arg = [[NSString alloc] initWithData:_data encoding:self.encoding];
        id userInfo = self.userInfo;
        callBackSuccess(arg,userInfo);
    }
    [self cancel];
}
-(void) cancel{
    @synchronized(_connection){
        if (self.connection) {
            [self.connection cancel];
            self.userInfo=nil;
            self.requestString = nil;
            callBackFaild = nil;
            callBackSuccess = nil;
        }
    }
}
-(void) dealloc{
    [self cancel];
}
@end
