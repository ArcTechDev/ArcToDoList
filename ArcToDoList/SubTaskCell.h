//
//  SubTaskCell.h
//  ArcToDoList
//
//  Created by User on 4/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "SubTableViewCell.h"

@protocol SubTaskCellDelegate <NSObject>

@optional
- (void)onNotificationForTaskIndex:(NSInteger)taskIndex;
- (void)onNoteForTaskIndex:(NSInteger)taskIndex;
- (void)onAttachmentForTaskIndex:(NSInteger)taskIndex;
- (void)onCatagorizeForTaskIndex:(NSInteger)taskIndex;

@end

@interface SubTaskCell : SubTableViewCell

@property (weak, nonatomic) id<SubTaskCellDelegate> theDelegate;

@end
