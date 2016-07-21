//
//  DateHelper.h
//  ArcToDoList
//
//  Created by User on 15/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * e.g 2006-07-12
 * readable formate year-month-day
 * formate yyyy-MM-dd
 */
#define DateFormateString @"yyyy-MM-dd"

/**
 * e.g 2006-07-12 20-05-03 (24 hours)
 * readable formate year-month-day hour:minute:second
 * formate yyyy-MM-dd HH:mm:ss
 */
#define DateTimeFormateString @"yyyy-MM-dd HH:mm:ss"

@interface DateHelper : NSObject

+ (NSString *)stringFromDate:(NSDate *)date withFormate:(NSString *)formate;
+ (NSDate *)dateFromString:(NSString *)dateStr withFormate:(NSString *)formate;
+ (NSDate *)dateToGMT:(NSDate *)sourceDate;

@end
