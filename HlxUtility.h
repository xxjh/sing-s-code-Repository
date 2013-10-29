//
//  HlxUtility.h
//  CarTrackerProj
//
//  Created by sing on 12-8-29.
//  Copyright (c) 2012年 sing. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum flipDirection {
    FlipDirection_ToLeft = 0,
    FlipDirection_ToRight = 1
} FlipDirection;

typedef enum moveDirection {
    MoveDirection_Left = -1,
    MoveDirection_Right = 1
} MoveDirection;

#pragma mark - HlxResponseObj

@interface HlxResponseObj : NSObject

@property (nonatomic, assign) NSInteger totalRecords;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, retain) id responseData;

@end

#pragma mark - Utility Functions

@interface HlxUtility : NSObject

+ (UIView*)showLoadingIndicatorView:(BOOL)show
                         parentView:(UIView*)parentView;

+ (UIView*)showLoadingIndicatorView:(BOOL)show
                         parentView:(UIView*)parentView
              includeBackgroundView:(BOOL)include
                        displayText:(NSString*)displayText;

+ (void)hideLoadingIndicatorView:(UIView*)parentView;

+ (void)showTipViewWithParentView:(UIView*)parentView
                          tipText:(NSString*)aTipText;

+ (void)showEmptyRecordTip:(UIView*)parentView;

+ (void)makeViewRoundCorner:(UIView *)aView
                 withRadius:(CGFloat)aRadius
                borderColor:(UIColor*)aColor
                borderWidth:(CGFloat)aWidth;

+ (NSString*)documentsDirectory;
+ (NSString*)tmpDirectory;
+ (UIColor *) getColor: (NSString *) hexColor;
+ (CGSize)calculateLabelSizeInDefaultScreenOfContent:(NSString*)text withFont:(UIFont*)font;
+ (CGSize)calculateLabelSizeOfContent:(NSString*)text withFont:(UIFont*)font maxSize:(CGSize)aMaxSize;
+ (void)flipView:(UIView*)targetView withDirection:(FlipDirection)direction target:(id)target stopAnimationSelector:(SEL)selector;
+ (void)moveView:(UIView*)view inSuperView:(UIView*)superView withDirection:(MoveDirection)direction;
+ (UIImage*)scaleAndRotateImage:(UIImage*)photoimage :(CGFloat)bounds_width :(CGFloat)bounds_height;
+ (void)adjustViewToFixBounds:(UIView*)view;

+ (UIImage*)hlxItemPlaceholderImage;
+ (UIColor*)UIColorFromHex:(NSInteger)colorInHex;

+ (NSString*)urlEncodeWithGBKEncode:(NSString*)srcString;
+ (NSString*)urlEncodeWithUTF8Encode:(NSString*)srcString;

+ (NSString*)urlDecodeWithGbkEncode:(NSString*)srcString;
+ (NSString*)urlDecodeWithUTF8Encode:(NSString*)srcString;

+ (NSString*)systemTimeStamp;
+ (NSString*)MD5:(NSString *)srcString;
+ (NSString*)convertToGbkEncodingString:(NSString*)srcString;
+ (NSData*)gbkDataConverToUtf8EncodingData:(NSData*)data;

#pragma mark - json parser

+ (id)parseJSONWithResultsList:(NSArray*)aResultList
                          Keys:(NSArray *)aKeys
                     itemClass:(Class)aItemClass
                      itemKeys:(NSArray*)aItemKeys;

+ (id)parseJSONWithString:(NSString*)aJSONString
            resultListKey:(NSString*)aListKey
                     Keys:(NSArray *)aKeys
                itemClass:(Class)aItemClass
                 itemKeys:(NSArray*)aItemKeys;

+ (id)parseJSONWithResultsString:(NSString*)aResultString
                     itemClass:(Class)aItemClass;
+ (id)parseJSONWithResultsList:(NSArray*)aResultList
                     itemClass:(Class)aItemClass;
+ (id)itemParseWithResultDictionary:(NSDictionary*)itemDict
                          itemClass:(Class)itemClass;

@end

#pragma mark - external functions

@interface UIImage (exUIImage)

- (UIImage*)cutImageInBound:(CGRect)rect;

@end
