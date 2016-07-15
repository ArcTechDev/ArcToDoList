//
//  DateHelper.m
//  ArcToDoList
//
//  Created by User on 15/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

static NSDateFormatter *dateFormatter;

+ (NSString *)stringFromDate:(NSDate *)date withFormate:(NSString *)formate{
    
    if(dateFormatter == nil)
        dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:formate];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)dateStr withFormate:(NSString *)formate{
    
    if(dateFormatter == nil)
        dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:formate];
    
    return [dateFormatter dateFromString:dateStr];
}

@end
