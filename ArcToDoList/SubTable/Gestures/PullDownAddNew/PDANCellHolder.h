//
//  PDANCellHolder.h
//  NPTableView
//
//  Created by User on 20/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDANCellHolderDelegate <NSObject>

@optional
-(void)endEditWithText:(NSString *)text;

@end

@interface PDANCellHolder : UIView<UITextFieldDelegate>

@property (weak, nonatomic) id<PDANCellHolderDelegate> delegate;

+ (id)CellHolderWithNibName:(NSString *)nibName;

- (void)startEdit;

- (void)changeItemText:(NSString *)text;

@end
