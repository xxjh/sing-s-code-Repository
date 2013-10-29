//
//  HlxUtility.m
//  CarTrackerProj
//
//  Created by sing on 12-8-29.
//  Copyright (c) 2012年 sing. All rights reserved.
//

#import "HlxUtility.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "ARCMacros.h"
#import <CommonCrypto/CommonDigest.h>

#define kLoadingIndicatorViewTag        1234
#define kLoadingIndicatorBgViewTag      1235
#define kLoadingIndicatorTextLabelTag   1236

#define APP_DIRECTORY                   @"AppDirectory_"

#pragma mark - HlxResponseObj

@implementation HlxResponseObj

- (void)dealloc
{
    SAFE_ARC_RELEASE(_responseData);
    SAFE_ARC_SUPER_DEALLOC();
}

@end

#pragma mark - HlxUtility

@implementation HlxUtility

#pragma mark - indicator

+ (UIView*)showLoadingIndicatorView:(BOOL)show
                         parentView:(UIView*)parentView
{
    const CGFloat indictorWidth = 32;
    const CGFloat indictorHeight = 32;
    CGFloat top, left;
    
    UIActivityIndicatorView *indicatorView = nil;
    
    if (show) {
        
        //remove first if exists
        indicatorView = (UIActivityIndicatorView*)[parentView viewWithTag:kLoadingIndicatorViewTag];
        if (indicatorView != nil && [indicatorView isKindOfClass:[UIActivityIndicatorView class]]) {
            [indicatorView removeFromSuperview];
        }
        
        //show!!
        CGFloat width= parentView.frame.size.width, height = parentView.frame.size.height;
        
        left = (width - indictorWidth) / 2;
        top = (height - indictorHeight) / 2;
        
        //indicator view
        indicatorView = SAFE_ARC_AUTORELEASE([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]);
        indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        indicatorView.tag = kLoadingIndicatorViewTag;
        indicatorView.frame = CGRectMake(left, top, indictorWidth, indictorHeight);
        [parentView addSubview:indicatorView];
        [parentView bringSubviewToFront:indicatorView];
        parentView.userInteractionEnabled = NO;
        [indicatorView startAnimating];
        
    } else {
        indicatorView = (UIActivityIndicatorView*)[parentView viewWithTag:kLoadingIndicatorViewTag];
        if (indicatorView != nil && [indicatorView isKindOfClass:[UIActivityIndicatorView class]]) {
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
        }
        parentView.userInteractionEnabled = YES;
    }
    return indicatorView;
}

+ (UIView*)showLoadingIndicatorView:(BOOL)show
                         parentView:(UIView*)parentView
              includeBackgroundView:(BOOL)include
                        displayText:(NSString*)displayText
{
    const CGFloat indictorWidth = 24;
    const CGFloat indictorHeight = 24;
    const CGFloat bgViewWidth = 100;
    const CGFloat bgViewHeight = 70;
    CGFloat top, left;
    
    UIView *bgView = nil;
    UIActivityIndicatorView *indicatorView = nil;
    
    @synchronized(self) {
        
        if (show) {
            
            //remove first if exists
            UIView *indicatorBgView = [parentView viewWithTag:kLoadingIndicatorBgViewTag];
            if (indicatorBgView != nil && [indicatorBgView superview] != nil) {
                [indicatorBgView removeFromSuperview];
            }
            
            
            CGFloat width= parentView.frame.size.width, height = parentView.frame.size.height;
            
            left = (width - bgViewWidth) / 2;
            top = (height - bgViewHeight) / 2;
            
            //bgView
            bgView = SAFE_ARC_AUTORELEASE([[UIView alloc] initWithFrame:CGRectMake(left, top, bgViewWidth, bgViewHeight)]);
            bgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            bgView.backgroundColor = [UIColor blackColor];
            bgView.alpha = 0.8;
            bgView.tag = kLoadingIndicatorBgViewTag;
            [parentView addSubview:bgView];
            [parentView bringSubviewToFront:bgView];
            parentView.userInteractionEnabled = NO;
            
            //set to round conrner
            [self makeViewRoundCorner:bgView withRadius:10.0 borderColor:nil borderWidth:0];
            
            //indicator view
            indicatorView = SAFE_ARC_AUTORELEASE([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]);
            left = (bgViewWidth - indictorWidth) / 2;
            top = (bgViewHeight - indictorHeight) / 2;
            indicatorView.tag = kLoadingIndicatorViewTag;
            indicatorView.frame = CGRectMake(left, top - top / 2, indictorWidth, indictorHeight);
            [bgView addSubview:indicatorView];
            [indicatorView startAnimating];
            
            //label
            CGFloat labelHeight = 20;
            UILabel *textLabel = SAFE_ARC_AUTORELEASE([[UILabel alloc] initWithFrame:CGRectMake(0, top + top / 2, bgViewWidth, labelHeight)]);
            textLabel.tag = kLoadingIndicatorTextLabelTag;
            NSString *displayTxt = displayText;
            if (displayTxt == nil) {
                displayTxt = @"正在加载...";
            }
            textLabel.text = displayTxt;
            textLabel.font = [UIFont systemFontOfSize:12];
            textLabel.textColor = [UIColor whiteColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            //        textLabel.verticalAlignment = VerticalAlignmentMiddle;
            textLabel.backgroundColor = [UIColor clearColor];
            [bgView addSubview:textLabel];
            
            //bgView release
        } else {
            bgView = (UIView*)[parentView viewWithTag:kLoadingIndicatorBgViewTag];
            if (bgView != nil) {
                indicatorView = (UIActivityIndicatorView*)[bgView viewWithTag:kLoadingIndicatorViewTag];
                if (indicatorView != nil && [indicatorView superview] != nil) {
                    [indicatorView stopAnimating];
                    [indicatorView removeFromSuperview];
                }
                UILabel *label = (UILabel*)[bgView viewWithTag:kLoadingIndicatorTextLabelTag];
                if (label != nil && [label superview] != nil) {
                    [label removeFromSuperview];
                }
                if ([bgView superview] != nil) {
                    [bgView removeFromSuperview];
                }
            }
            parentView.userInteractionEnabled = YES;
        }
        
    }
    
    return bgView;
}

+ (void)hideLoadingIndicatorView:(UIView*)parentView
{
    UIActivityIndicatorView *indicatorView = nil;
    UIView *bgView = (UIView*)[parentView viewWithTag:kLoadingIndicatorBgViewTag];
    
    if (bgView != nil) {    //indicator with background view
        indicatorView = (UIActivityIndicatorView*)[bgView viewWithTag:kLoadingIndicatorViewTag];
        if (indicatorView != nil && [indicatorView superview] != nil) {
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
        }
        UILabel *label = (UILabel*)[bgView viewWithTag:kLoadingIndicatorTextLabelTag];
        if (label != nil && [label superview] != nil) {
            [label removeFromSuperview];
        }
        if ([bgView superview] != nil) {
            [bgView removeFromSuperview];
        }
    } else {    //indicator not include background view
        indicatorView = (UIActivityIndicatorView*)[parentView viewWithTag:kLoadingIndicatorViewTag];
        if (indicatorView != nil && [indicatorView superview] != nil) {
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
        }
    }
    parentView.userInteractionEnabled = YES;
}

+ (void)showTipViewWithParentView:(UIView*)parentView
                          tipText:(NSString*)aTipText
{
    NSAssert(parentView != nil, @"parent view is nil!");
    
    CGRect frame = parentView.frame;
    const NSInteger labelWidth = 100;
    const NSInteger labelHeight = 70;
    const NSInteger padding = 5;
    UIFont *font = [UIFont systemFontOfSize:14.0];
    
    CGSize maxSize = CGSizeMake(200, 100);
    CGSize actualSize = [HlxUtility calculateLabelSizeOfContent:aTipText withFont:font maxSize:maxSize];
    actualSize.width += padding * 2;
    actualSize.height += padding * 2;
    
    if (actualSize.width < labelWidth) {
        actualSize.width = labelWidth;
    }
    if (actualSize.height < labelHeight) {
        actualSize.height = labelHeight;
    }
    
    CGRect labelFrame = CGRectMake((frame.size.width - actualSize.width) / 2, (frame.size.height - actualSize.height) / 2, actualSize.width, actualSize.height);
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:labelFrame];
    tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    tipLabel.text = aTipText;
    tipLabel.font = font;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.backgroundColor = [UIColor darkGrayColor];
    tipLabel.alpha = 0.0f;
    tipLabel.numberOfLines = 0;
    [parentView addSubview:tipLabel];
	[parentView bringSubviewToFront:tipLabel];
    
    //set to round conrner
    [self makeViewRoundCorner:tipLabel withRadius:10.0 borderColor:nil borderWidth:0];
    
    //animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0f];
	tipLabel.alpha = 1.0f;
	[UIView commitAnimations];
    
    [UIView animateWithDuration:2.0f animations:^{tipLabel.alpha = 0.0f;} completion:^(BOOL finished){if (finished) [tipLabel removeFromSuperview];}];
    
}

+ (void)showEmptyRecordTip:(UIView*)parentView
{
    [self showTipViewWithParentView:parentView tipText:@"记录为空"];
}

+ (void)makeViewRoundCorner:(UIView *)aView
                 withRadius:(CGFloat)aRadius
                borderColor:(UIColor*)aColor
                borderWidth:(CGFloat)aWidth
{
    aView.layer.cornerRadius = aRadius;
    aView.layer.masksToBounds = YES;
    aView.layer.opaque = NO;
    
    if (aColor != nil) {
        aView.layer.borderColor = [aColor CGColor];
        aView.layer.borderWidth = aWidth;
    }
}

//get tmp directory
+ (NSString*)documentsDirectory
{
    NSString *documentsDirectory = nil;
    
    //documentDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    //        NSLog(@"doc path : %@", docDir);
    if (docDir != nil) {
        documentsDirectory = [[NSString alloc] initWithFormat:@"%@", [docDir stringByAppendingPathComponent:APP_DIRECTORY]];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return SAFE_ARC_AUTORELEASE(documentsDirectory);
}

//tmp directory
+ (NSString*)tmpDirectory
{
    NSString *tmpDirectory = nil;
    //tmp directory
    NSString *tmpDir = NSTemporaryDirectory();
    if (tmpDir != nil) {
        tmpDirectory = [[NSString alloc] initWithFormat:@"%@", [tmpDir stringByAppendingPathComponent:APP_DIRECTORY]];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:tmpDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return SAFE_ARC_AUTORELEASE(tmpDirectory);
}

// Convert a 6-character hex color to a UIColor object
+ (UIColor *) getColor: (NSString *) hexColor
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

//default screen is with 320 default width
+ (CGSize)calculateLabelSizeInDefaultScreenOfContent:(NSString*)text withFont:(UIFont*)font
{
    CGSize defMaxSize = CGSizeMake(320, 1000);
    return [self calculateLabelSizeOfContent:text withFont:font maxSize:defMaxSize];
}

//根据字体大小自动计算label大小
+ (CGSize)calculateLabelSizeOfContent:(NSString*)text withFont:(UIFont*)font maxSize:(CGSize)aMaxSize
{
    const CGSize defaultSize = CGSizeMake(320, 22);
    
    if (text == nil || text.length == 0) {
        return defaultSize;
    }
    
    CGSize labelSize = CGSizeZero;
    if ([text isKindOfClass:[NSString class]]) {
        labelSize = [text sizeWithFont:font constrainedToSize:aMaxSize lineBreakMode:NSLineBreakByWordWrapping];
        if (labelSize.height < defaultSize.height) {
            labelSize.height = defaultSize.height;
        }
    }
    return labelSize;
}

+ (void)flipView:(UIView*)targetView withDirection:(FlipDirection)direction target:(id)target stopAnimationSelector:(SEL)selector
{
    NSInteger transition = UIViewAnimationTransitionFlipFromRight;
    if (direction == FlipDirection_ToRight) {
        transition = UIViewAnimationTransitionFlipFromLeft;
    }
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:transition forView:targetView cache:YES];
	[UIView setAnimationDelegate:target];
	[UIView setAnimationDidStopSelector:selector];
	[UIView commitAnimations];
}

+ (void)moveView:(UIView*)view inSuperView:(UIView*)superView withDirection:(MoveDirection)direction
{
    NSParameterAssert(view != nil);
    
    CGRect originalRC = view.frame;
    CGRect destRC = originalRC;
    
    destRC.origin.x += originalRC.size.width * direction;
    
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         view.frame = destRC;
                         if (destRC.origin.x == 0 && [view superview] == nil)
                             [superView addSubview:view];
                     }
                     completion:^(BOOL finished) {
                         if (destRC.origin.x != 0 && [view superview] != nil)
                             [view removeFromSuperview];
                     }];
    
}

+ (UIImage*)scaleAndRotateImage:(UIImage*)photoimage :(CGFloat)bounds_width :(CGFloat)bounds_height
{
    NSParameterAssert(bounds_width != NSIntegerMax || bounds_height != NSIntegerMax);
    
    if (photoimage == nil) {
        NSParameterAssert(photoimage != nil);
        return nil;
    }
    
    //int kMaxResolution = 300;
    
    CGImageRef imgRef =photoimage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if (width < bounds_width) {
        bounds_width = width;
    }
    if (height < bounds_height) {
        bounds_height = height;
    }
    
    //if bounds_width or bounds_height is equal to NSIntegerMax, scale base on the other
    //
    CGFloat scaleValue = 1.0;
    if (bounds_width == NSIntegerMax && bounds_height < height) {
        scaleValue = width / height;    //scale base on height
        bounds_width = scaleValue * bounds_height;
    } else if (bounds_height == NSIntegerMax && bounds_width < width) {
        scaleValue = height / width;    //scale base on width
        bounds_height = scaleValue * bounds_width;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    /*if (width > kMaxResolution || height > kMaxResolution)
     {
     CGFloat ratio = width/height;
     if (ratio > 1)
     {
     bounds.size.width = kMaxResolution;
     bounds.size.height = bounds.size.width / ratio;
     }
     else
     {
     bounds.size.height = kMaxResolution;
     bounds.size.width = bounds.size.height * ratio;
     }
     }*/
    bounds.size.width = bounds_width;
    bounds.size.height = bounds_height;
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGFloat scaleRatioheight = bounds.size.height / height;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient =photoimage.imageOrientation;
    switch(orient)
    {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid?image?orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatioheight);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatioheight);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

+ (void)adjustViewToFixBounds:(UIView*)view
{
    NSParameterAssert(view != nil);
    
    const CGFloat statusBarHeight = 20.0;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = view.frame;
    frame.size.height = bounds.size.height - statusBarHeight;
    view.frame = frame;
}

+ (UIImage*)hlxItemPlaceholderImage
{
    UIImage *img = [UIImage imageNamed:@"itemPlaceholder.png"];
    return img;
}

+ (UIColor*)UIColorFromHex:(NSInteger)colorInHex {
    // colorInHex should be value like 0xFFFFFF
    return [UIColor colorWithRed:((float) ((colorInHex & 0xFF0000) >> 16)) / 0xFF
                           green:((float) ((colorInHex & 0xFF00)   >> 8))  / 0xFF
                            blue:((float)  (colorInHex & 0xFF))            / 0xFF
                           alpha:1.0];
}

#pragma mark -
#pragma mark url encode and decode

char* urlencode(unsigned char *string) {
    
    int escapecount = 0;
    
    unsigned char *src, *dest;
    
    unsigned char *newstr;
    
    
    char hextable[] = { '0', '1', '2', '3', '4', '5', '6', '7',
        
        '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    
    
    if (string == NULL) return NULL;
    
    
    for (src = string; *src != 0; src++)
        
        if (!isalnum(*src)) escapecount++;
    
    newstr = (unsigned char *)malloc(strlen((const char*)string) - escapecount + (escapecount * 3) + 1);
    
    
    src = string;
    
    dest = newstr;
    
    while (*src != 0) {
        
        if (!isalnum(*src)) {
            
            *dest++ = '%';
            
            *dest++ = hextable[*src >> 4];
            
            *dest++ = hextable[*src & 0x0F];
            
            src++;
            
        } else {
            
            *dest++ = *src++;
            
        }
        
    }
    
    *dest = 0;
    
    
    return (char*)newstr;
    
}

+ (NSString*)urlEncodeWithGBKEncode:(NSString*)srcString
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    const char *tempString = [srcString cStringUsingEncoding:gbkEncoding];
    char *strEncoded = urlencode((unsigned char*)tempString);
    NSString *rtnStr = [NSString stringWithFormat:@"%s", strEncoded];
    free(strEncoded);
    return rtnStr;
}

+ (NSString*)urlEncodeWithUTF8Encode:(NSString*)srcString
{
    if (srcString == nil) {
        return nil;
    }
    
    const char *tempString = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    char *strEncoded = urlencode((unsigned char*)tempString);
    NSString *rtnStr = [NSString stringWithFormat:@"%s", strEncoded];
    free(strEncoded);
    return rtnStr;
}

+ (NSString*)urlDecodeWithGbkEncode:(NSString*)srcString
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *result = [(NSString *)srcString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:gbkEncoding];
    return result;
}

+ (NSString*)urlDecodeWithUTF8Encode:(NSString*)srcString
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString*)systemTimeStamp
{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    
    return timeStr;
}

+ (NSString*)MD5:(NSString *)srcString
{
    const char *cStr = [srcString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*)convertToGbkEncodingString:(NSString*)srcString
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *gbkData = [srcString dataUsingEncoding:gbkEncoding];
    NSInteger len = gbkData.length;
    char *bytes = malloc(len + 1);
    [gbkData getBytes:bytes length:[gbkData length]];
    NSString *retString = [NSString stringWithCString:bytes encoding:gbkEncoding];
    free(bytes);
    return retString;
}

+ (NSData*)gbkDataConverToUtf8EncodingData:(NSData*)data
{
    if (data == nil) {
        NSLog(@"%s, %d data is nil!!", __FUNCTION__, __LINE__);
        return data;
    }
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *gbkStrData = SAFE_ARC_AUTORELEASE([[NSString alloc] initWithData:data encoding:gbkEncoding]);
    
    
    if (gbkStrData == nil) {
        NSAssert(gbkStrData != nil, @"conver to gbk data failed!");
        return data;
    }
    
    NSString *temp = [gbkStrData lowercaseString];
    NSRange foundRange = [temp rangeOfString:@"encoding=\"gbk\""];
    NSData *utf8Data = nil;
    //had found
    if (foundRange.location != NSNotFound) {
        NSString *utf8String = [gbkStrData stringByReplacingOccurrencesOfString:@"encoding=\"gbk\"" withString:@"encoding=\"utf-8\""];
        utf8Data = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        utf8Data = [gbkStrData dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return utf8Data;
}

#pragma mark - json parser

+ (id)parseJSONWithResultsList:(NSArray*)aResultList
                               Keys:(NSArray *)aKeys
                          itemClass:(Class)aItemClass
                           itemKeys:(NSArray*)aItemKeys
{
    NSMutableArray *returnList = SAFE_ARC_AUTORELEASE([[NSMutableArray alloc] initWithCapacity:1]);
    
    for (NSDictionary *dict in aResultList) {
        NSInteger i = 0;
        id resultItem = [[aItemClass alloc] init];
        for (NSString *key in aKeys) {
            id item = [dict objectForKey:key];
            NSString *itemKey = [aItemKeys objectAtIndex:i++];
            [resultItem setValue:item forKey:itemKey];
        }
        [returnList addObject:resultItem];
        SAFE_ARC_RELEASE(resultItem);
    }
    
    return returnList;
}

+ (id)parseJSONWithString:(NSString*)aJSONString
            resultListKey:(NSString*)aListKey
                     Keys:(NSArray *)aKeys
                itemClass:(Class)aItemClass
                 itemKeys:(NSArray*)aItemKeys
{
    NSDictionary *resultDict = [aJSONString objectFromJSONString];
    
    NSArray *resultList = [resultDict objectForKey:aListKey];
    return [self parseJSONWithResultsList:resultList Keys:aKeys itemClass:aItemClass itemKeys:aItemKeys];
}

+ (id)parseJSONWithResultsString:(NSString*)aResultString
                       itemClass:(Class)aItemClass
{
    NSArray *resultList = [aResultString objectFromJSONString];
    
    return [HlxUtility parseJSONWithResultsList:resultList itemClass:aItemClass];
}

+ (id)parseJSONWithResultsList:(NSArray*)aResultList
                     itemClass:(Class)aItemClass
{
    NSMutableArray *resultItemList = SAFE_ARC_AUTORELEASE([[NSMutableArray alloc] initWithCapacity:aResultList.count]);
    
    for (NSDictionary *dict in aResultList) {
        id itemResult = [HlxUtility itemParseWithResultDictionary:dict itemClass:aItemClass];
        [resultItemList addObject:itemResult];
    }
    
    return resultItemList;
}

+ (id)itemParseWithResultDictionary:(NSDictionary*)itemDict itemClass:(Class)itemClass
{
    id retItem = SAFE_ARC_AUTORELEASE([[[itemClass class] alloc] init]);

    /*
    //此种方式有缺陷：若itemClass为继承类，则取属性不能取到其父类的属性。
    //get value according property
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(itemClass, &outCount);
    if(outCount > 0) {
        for(NSInteger i = 0; i < outCount; i++) {
            NSString *name = [NSString stringWithCString: property_getName(properties[i]) encoding: NSUTF8StringEncoding];
            NSString *value = [itemDict objectForKey:name];
            [retItem setValue:value forKey:name];
        }
    }
    free(properties);
     */
    //get value according dictionary
    NSArray *allKeys = itemDict.allKeys;
    for (NSString *key in allKeys) {
        id value = [itemDict objectForKey:key];
        [retItem setValue:value forKey:key];
    }
    return retItem;
}

@end

#pragma mark - external functions

@implementation UIImage (exUIImage)

- (UIImage*)cutImageInBound:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return smallImage;
}

@end
