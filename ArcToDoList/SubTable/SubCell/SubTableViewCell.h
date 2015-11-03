//
//  SubTableView.h
//  SubTableView
//
//  Created by User on 26/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubTableViewCellDelegate <NSObject>

@required
- (NSInteger)numberOfChildrenCellUnderParentIndex:(NSInteger)parentIndex;
- (UITableViewCell *)tableView:(UITableView *)tableView childCellForRowAtIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;

@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;
- (CGFloat)tableView:(UITableView *)tableView childCellHeightForRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;

@end

@interface SubTableViewCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) NSInteger parentIndex;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;
@property (weak, nonatomic) id<SubTableViewCellDelegate> delegate;

- (void)reloadData;

@end
