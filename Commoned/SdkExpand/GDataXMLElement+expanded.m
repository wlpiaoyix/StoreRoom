//
//  GDataXMLElement+expanded.m
//  Common
//
//  Created by wlpiaoyi on 14-10-13.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "GDataXMLElement+expanded.h"

@implementation GDataXMLElement (expanded)


+(void) mergeXMLElement:(const GDataXMLElement*) mergeElement TargetElement:(const GDataXMLElement*) targetElement  Compare:(CallBackDataXMLElementCompare) compare{
    //节点属性
    for (GDataXMLNode *attribute in [mergeElement attributes]) {
        [self mergeElementAttribute:attribute.name MergeValue:attribute.stringValue TargetElement:targetElement];
    }
    NSArray *targetchildren = [targetElement children];
    NSMutableArray *mergechildren = [NSMutableArray arrayWithArray:[mergeElement children]];
    if (targetchildren&&[targetchildren count]) {
        for (GDataXMLElement *targetchild in targetchildren) {
            NSString *targetname = targetchild.name;
            int index = 0;
            for (GDataXMLElement *mergechid in mergechildren) {
                if ([self compareElement:mergechid TargetElement:targetchild Compare:compare]) {
                    [mergechildren removeObjectAtIndex:index];
                    [self mergeXMLElement:mergechid TargetElement:targetchild Compare:compare];
                    goto br;
                }
                index++;
            }
        br:targetname = targetname;
        }
        if (mergechildren&&[mergechildren count]) {
            for (GDataXMLElement *mergechid in mergechildren) {
                [targetElement addChild:mergechid];
            }
        }
    }else{
        for (GDataXMLElement *child in [mergeElement children]) {
            [targetElement addChild:child];
        }
    }
}

+(void) mergeElementAttribute:(NSString*) mergeName MergeValue:(NSString*) mergeValue TargetElement:(const GDataXMLElement*) targetElement{
    GDataXMLNode *node = [targetElement attributeForName:mergeName];
    if (node) {
        [node setStringValue:mergeValue];
    }
    if (!node) {
        GDataXMLNode *node = [GDataXMLNode elementWithName:mergeName stringValue:(NSString*)mergeValue];
        [targetElement addAttribute:node];
    }
}

+(BOOL) compareElement:(const GDataXMLElement*) mergeElement TargetElement:(const GDataXMLElement*) targetElement  Compare:(CallBackDataXMLElementCompare) compare{
    if (compare) {
        if (compare(mergeElement,targetElement)) {
            return true;
        }
    }else{
        if ([targetElement.name isEqualToString:mergeElement.name]) {
            return true;
        }
    }
    return false;
}

@end
