//
//  DLog.h
//  HomeTheaterStand-alone
//
//  Created by sing on 11-8-11.
//  Copyright 2011年 NetMovie. All rights reserved.
//


//添加定义，在release时不会输出log
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#ifndef __OPTIMIZE__
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) /* */
#endif

#define ALog(...) NSLog(__VA_ARGS__)

//add by heweixina
// ALog always displays output regardless of the DEBUG setting 
#define FLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); 