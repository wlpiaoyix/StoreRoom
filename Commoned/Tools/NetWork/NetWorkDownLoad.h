//
//  NetWorkDownLoad.h
//  Common
//
//  Created by wlpiaoyi on 14-10-18.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWork.h"

@interface NetWorkDownLoad : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,NetWorkDownLoadDelegate>

@end
