//
//  AutoLayoutKitTests.m
//  AutoLayoutKitTests
//
//  Created by Florian Krüger on 12/01/14.
//  Copyright (c) 2014 projectserver.org. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AutoLayoutKit.h"

NSString * const kALKTestConstraint = @"ALKTestConstraint";

@interface AutoLayoutKitTests : XCTestCase

@end

@implementation AutoLayoutKitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Basic Tests

- (void)testStopsTranslatingAutoresizingMasks
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  
  XCTAssertTrue(view.translatesAutoresizingMaskIntoConstraints, @"");
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {}];
  
  XCTAssertFalse(view.translatesAutoresizingMaskIntoConstraints, @"");
}

#pragma mark - Target View Tests

- (void)testCreatesUnrelatedConstraintOnTheGivenItemWhenUsingSet
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {
    [c set:ALKWidth to:100.f];
  }];
  
  NSArray *constraints = [view constraints];
  XCTAssertEqual([constraints count], (NSUInteger)1, @"");
}

- (void)testCreatedRelatedConstraintOnTheSpecifiedItemWhenUsingMakeOn
{
  UIView *parentView  = [[UIView alloc] initWithFrame:CGRectZero];
  UIView *childView   = [[UIView alloc] initWithFrame:CGRectZero];
  [parentView addSubview:childView];
  
  [ALKConstraints layout:childView do:^(ALKConstraints *c) {
    [c make:ALKWidth equalTo:parentView s:ALKWidth on:parentView];
  }];
  
  XCTAssertEqual([childView.constraints count],   (NSUInteger)0, @"");
  XCTAssertEqual([parentView.constraints count],  (NSUInteger)1, @"");
}

- (void)testCreatedRelatedConstraintOnTheParentItemWhenUsingMake
{
  UIView *parentView  = [[UIView alloc] initWithFrame:CGRectZero];
  UIView *childView   = [[UIView alloc] initWithFrame:CGRectZero];
  [parentView addSubview:childView];
  
  [ALKConstraints layout:childView do:^(ALKConstraints *c) {
    [c make:ALKWidth equalTo:parentView s:ALKWidth];
  }];
  
  XCTAssertEqual([childView.constraints count],   (NSUInteger)0, @"");
  XCTAssertEqual([parentView.constraints count],  (NSUInteger)1, @"");
}

- (void)testCreatedRelatedConstraintOnTheCommonParentItemWhenUsingMake
{
  UIView *parentView = [[UIView alloc] initWithFrame:CGRectZero];
  UIView *childView1 = [[UIView alloc] initWithFrame:CGRectZero];
  UIView *childView2 = [[UIView alloc] initWithFrame:CGRectZero];
  [parentView addSubview:childView1];
  [parentView addSubview:childView2];
  
  [ALKConstraints layout:childView1 do:^(ALKConstraints *c) {
    [c make:ALKWidth equalTo:childView2 s:ALKWidth];
  }];
  
  XCTAssertEqual([childView1.constraints count], (NSUInteger)0, @"");
  XCTAssertEqual([childView2.constraints count], (NSUInteger)0, @"");
  XCTAssertEqual([parentView.constraints count], (NSUInteger)1, @"");
}

#pragma mark - Named Constraints Tests

- (void)testRetrieveAConstraintByItsName
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  CGFloat constant = 111.f;
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {
    [c set:ALKWidth to:constant name:kALKTestConstraint];
  }];
  
  NSLayoutConstraint *constraint = [view alk_constraintWithName:kALKTestConstraint];
  
  XCTAssertNotNil(constraint, @"");
  XCTAssertEqualWithAccuracy(constraint.constant, constant, 0.001, @"");
}

- (void)testRetrieveNonExistingConstraintByName
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {
    [c set:ALKWidth to:111.f];
  }];
  
  XCTAssertNil([view alk_constraintWithName:kALKTestConstraint], @"");
}

- (void)testNotPossibleToAddTwoConstraintsWithTheSameName
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  CGFloat constant1 = 111.f;
  CGFloat constant2 = 222.f;
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {
    [c set:ALKWidth to:constant1 name:kALKTestConstraint];
  }];
  
  NSLayoutConstraint *constraint = [view alk_constraintWithName:kALKTestConstraint];
  
  XCTAssertNotNil(constraint, @"");
  XCTAssertEqualWithAccuracy(constraint.constant, constant1, 0.001, @"");
  
  [ALKConstraints layout:view do:^(ALKConstraints *c) {
    [c set:ALKHeight to:constant2 name:kALKTestConstraint];
  }];
  
  constraint = [view alk_constraintWithName:kALKTestConstraint];
  
  XCTAssertNotNil(constraint, @"");
  XCTAssertEqualWithAccuracy(constraint.constant, constant1, 0.001, @"");
  XCTAssertNotEqualWithAccuracy(constraint.constant, constant2, 0.001, @"");
}

#pragma mark - Layout Tests (SET)

//- (void)testLayout
//{
//  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
//  
//  [ALKConstraints layout:view do:^(ALKConstraints *c) {
//    [c set:ALKWidth to:100.f];
//  }];
//  
//  [view.constraints count]
//}

@end