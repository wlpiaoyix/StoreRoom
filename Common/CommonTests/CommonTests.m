//
//  CommonTests.m
//  CommonTests
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RegexPredicate.h"

@interface CommonTests : XCTestCase

@end

@implementation CommonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    BOOL flag = [RegexPredicate matchFloat:@"123.44"];
    flag = [RegexPredicate matchFloat:@"1234"];
    flag = [RegexPredicate matchInteger:@"123.4"];
    flag = [RegexPredicate matchInteger:@"1234"];
    flag = [RegexPredicate matchPhoneNum:@"18228088049"];
    flag = [RegexPredicate matchPhoneNum:@"38228088049"];
    flag = [RegexPredicate matchPhoneNum:@"1822808804"];
    flag = [RegexPredicate matchEmail:@"qqpiaoyi@126.com"];
    flag = [RegexPredicate matchEmail:@"126.com"];
    flag = [RegexPredicate matchEmail:@"afaf@126"];
    flag = [RegexPredicate matchEmail:@"qqpiaoyi@eei.com"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
