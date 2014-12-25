//
//  GDataXMLElement+expanded.h
//  Common
//
//  Created by wlpiaoyi on 14-10-13.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "GDataXMLNode.h"
//回调通用方法
typedef BOOL (^CallBackDataXMLElementCompare)(const GDataXMLElement *mergeElement, const GDataXMLElement *targetElement);

@interface GDataXMLElement (expanded)
/**
 xml数据合并
 mergeElement:用来合并的数据
 targetElement:被合并的数据
 compare:对象之间的对比规则
 */
+(void) mergeXMLElement:(const GDataXMLElement*) mergeElement TargetElement:(const GDataXMLElement*) targetElement  Compare:(CallBackDataXMLElementCompare) compare;

@end
