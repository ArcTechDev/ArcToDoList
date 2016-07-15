//
//  DateHelper.h
//  ArcToDoList
//
//  Created by User on 15/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DateFormateString @"yyyy-MM-dd"

@interface DateHelper : NSObject

+ (NSString *)stringFromDate:(NSDate *)date withFormate:(NSString *)formate;
+ (NSDate *)dateFromString:(NSString *)dateStr withFormate:(NSString *)formate;

@end
