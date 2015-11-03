//
//  DTECellHolder.h
//  SubTableView
//
//  Created by User on 28/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTECellHolderDelegate <NSObject>

@optional
-(void)endEditWithText:(NSString *)text;

@end

@interface DTECellHolder : UIView<UITextFieldDelegate>

@property (weak, nonatomic) id<DTECellHolderDelegate> delegate;

+ (id)CellHolderWithNibName:(NSString *)nibName;

- (void)startEdit;

- (void)changeItemText:(NSString *)text;

@end
