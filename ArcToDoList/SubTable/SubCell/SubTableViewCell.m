//
//  SubTableView.m
//  SubTableView
//
//  Created by User on 26/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "SubTableViewCell.h"
#import "ChildTableViewCell.h"

@implementation SubTableViewCell

@synthesize parentIndex = _parentIndex;
@synthesize subTableView = _subTableView;
@synthesize delegate = _delegate;

- (void)awakeFromNib {
    // Initialization code
    
    [_subTableView setDataSource:self];
    [_subTableView setDelegate:self];
    [_subTableView setBounces:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public interface
- (void)reloadData{
    
    [_subTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [_delegate numberOfChildrenCellUnderParentIndex:_parentIndex];
    
    if (count > 0)
        return count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChildTableViewCell *childCell = (ChildTableViewCell *)[_delegate tableView:_subTableView childCellForRowAtIndex:indexPath.row underParentIndex:_parentIndex];
    
    childCell.parentIndex = _parentIndex;
    
    return childCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([_delegate respondsToSelector:@selector(tableView:didSelectRowAtChildIndex:underParentIndex:)]){
        
        [_delegate tableView:_subTableView didSelectRowAtChildIndex:indexPath.row underParentIndex:_parentIndex];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([_delegate respondsToSelector:@selector(tableView:childCellHeightForRowAtChildIndex:underParentIndex:)]){
        
        return [_delegate tableView:_subTableView childCellHeightForRowAtChildIndex:indexPath.row underParentIndex:_parentIndex];
    }
    
    return 44.0f;
}

@end
