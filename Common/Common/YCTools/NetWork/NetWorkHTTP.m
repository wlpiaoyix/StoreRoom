//
//  NetWorkRequest.m
//  Common
//
//  Created by wlpiaoyi on 14-10-7.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "NetWorkHTTP.h"
#import "JSON.h"
//==>传输方法
#define GET @"GET"
#define POST @"POST"
#define PUT @"PUT"
#define DELETE @"DELETE"
//<==
#define HTTP_HEAD_KEY_ContentType @"Content-Type"
#define HTTP_HEAD_VALUE_ContentType_JSON  @"application/json"

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
//        [self addRequestHeadValue:@{@"content-type":@"application/x-www-form-urlencoded"}];
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
    _requestString= [requestString stringByAddingPercentEscapesUsingEncoding:self.encoding];
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
    [self startAsynRequest];
}
-(void) requestPUT:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createDataRequest:params OutTime:outTime];
    [_request setHTTPMethod:PUT];
    [self startAsynRequest];
}
-(void) requestGET:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createUrlRequest:params OutTime:outTime];
    [_request setHTTPMethod:GET];
    [self startAsynRequest];
}
-(void) requestDELETE:(NSDictionary*) params OutTime:(int) outTime{
    _request = [self createUrlRequest:params OutTime:outTime];
    [_request setHTTPMethod:DELETE];
    [self startAsynRequest];
}
-(NSString*) checkParamsConstruction:(NSDictionary*) dicParam{
    if (!dicParam) {
        return nil;
    }
    NSString *contentType = [self.httpHeaderFields objectForKey:HTTP_HEAD_KEY_ContentType];
    if ([((NSString*)HTTP_HEAD_VALUE_ContentType_JSON) isEqualToString:contentType]) {
        return [dicParam JSONRepresentation];
    }
    return [self checkParamsConstructionToNormarl:dicParam];
}
-(NSString*) checkParamsConstructionToNormarl:(NSDictionary*) dicParam{
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
    NSString *temp = params?[NSString stringWithFormat:@"%@?%@",self.requestString,[[self checkParamsConstructionToNormarl:params] stringByAddingPercentEscapesUsingEncoding:self.encoding]]:self.requestString;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: temp] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:outTime];
    if (self.httpHeaderFields) {
        [self addAllHttpHeaderFields:self.httpHeaderFields Request:request];
    }
    return request;
}
-(NSMutableURLRequest*) createDataRequest:(NSDictionary*) params OutTime:(int) outTime{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestString]  cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:outTime];
    if (params) {
        NSData *postData = [[self checkParamsConstruction:params] dataUsingEncoding:self.encoding  allowLossyConversion:YES];
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
    [_connection start];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _data = [NSMutableData new];
    
    // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        NSLog(@"allHeaderFields: %@",dictionary);
    }

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
//
//
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//}
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    static CFArrayRef certs;
//    if (!certs) {
//        NSData*certData =[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"srca" ofType:@"cer"]];
//        SecCertificateRef rootcert =SecCertificateCreateWithData(kCFAllocatorDefault,CFBridgingRetain(certData));
//        const void *array[1] = { rootcert };
//        certs = CFArrayCreate(NULL, array, 1, &kCFTypeArrayCallBacks);
//        CFRelease(rootcert);    // for completeness, really does not matter
//    }
//    
//    SecTrustRef trust = [[challenge protectionSpace] serverTrust];
//    int err;
//    SecTrustResultType trustResult = 0;
//    err = SecTrustSetAnchorCertificates(trust, certs);
//    if (err == noErr) {
//        err = SecTrustEvaluate(trust,&trustResult);
//    }
//    CFRelease(trust);
//    BOOL trusted = (err == noErr) && ((trustResult == kSecTrustResultProceed)||(trustResult == kSecTrustResultConfirm) || (trustResult == kSecTrustResultUnspecified));
//    
//    if (trusted) {
//        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    }else{
//        [challenge.sender cancelAuthenticationChallenge:challenge];
//    }
//}

-(void) dealloc{
    [self cancel];
}
@end
