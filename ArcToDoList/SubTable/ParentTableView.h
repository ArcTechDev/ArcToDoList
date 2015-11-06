//
//  ParentTableView.h
//  SubTableView
//
//  Created by User on 26/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

/**
 * ParentTableView is main tableView that will display ParentTableViewCell.
 * Eeach ParentTableViewCell will have a SubTableViewCell which act as a cell in ParentTableView.
 * Each SubTableViewCell have a tableView that will have many of ChildTableViewCell.
 *
 * ParentTableView --
 *                            --ParentTableViewCell
 *                            --SubTableViewCell --
 *                                                             --UITableView --
 *                                                                                    --ChildTableViewCell
 */

#import <UIKit/UIKit.h>
#import "SubTableViewCell.h"

@class ParentTableView;
@class GestureComponent;
@class ParentTableViewCell;

@protocol ParentTableViewDelegate <NSObject>

@required
/**
 * How many parent cell in tableView
 */
- (NSInteger)numberOfParentCellIsInTableView:(ParentTableView *)tableView;

/**
 * The parent cell at index
 */
- (UITableViewCell *)tableView:(ParentTableView *)tableView parentCellForRowAtIndex:(NSInteger)index;

/**
 * The sub cell under parent cell index
 */
- (UITableViewCell *)tableView:(ParentTableView *)tableView subCellRowUnderParentIndex:(NSInteger)parentIndex;

/**
 * Number of child cell under parent index
 */
- (NSInteger)numberOfChildrenCellUnderParentIndex:(NSInteger)parentIndex;

/**
 * Child cell for index in sub cell and under certain parent index
 */
- (UITableViewCell *)tableView:(UITableView *)tableView childCellForRowAtIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;


@optional
/**
 * Notify when tableView about to enter edit mode
 */
- (void)tableViewWillEnterEditMode:(ParentTableView *)tableView;

/**
 * Notify when tableView about to exist edit mode
 */
- (void)tableViewWillExitEditMode:(ParentTableView *)tableView;

/**
 * Parent cell height at index default is 44
 */
- (CGFloat)tableView:(ParentTableView *)tableView parentCellHeightForRowAtIndex:(NSInteger )index;

/**
 *Sub cell height at index  default is 44
 */
- (CGFloat)tableView:(ParentTableView *)tableView subCellHeightForRowAtIndex:(NSInteger)index underParentIndex:(NSInteger)parentIndex;

/**
 * Return YES to allow parent cell to be expand otherwise NO
 */
- (BOOL)tableView:(ParentTableView *)tableView canExpandSubCellForRowAtIndex:(NSInteger)index;

//- (void)tableView:(ParentTableView *)tableView didSelectRowAtIndex:(NSInteger)index;

/**
 * Will expand Parent cell at index
 */
- (void)tableView:(ParentTableView *)tableView willExpandForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex;

/**
 * Parent cell expend at index
 */
- (void)tableView:(ParentTableView *)tableView didExpandForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex;

/**
 * Will collapse Parent cell at index
 */
- (void)tableView:(ParentTableView *)tableView willCollapseForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex;

/**
 * Parent cell collapse at index
 */
- (void)tableView:(ParentTableView *)tableView didCollapseForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex;

//- (void)tableView:(UITableView *)tableView didSelectRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;

/**
 * Child cell height at child index under parent index
 */
- (CGFloat)tableView:(UITableView *)tableView childCellHeightForRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex;

@end

@interface ParentTableView : UITableView<UITableViewDataSource, UITableViewDelegate, SubTableViewCellDelegate>{

    NSMutableArray *_expansionStates;
}

@property (weak, nonatomic) IBOutlet id<ParentTableViewDelegate> theDelegate;
@property (assign, nonatomic) NSInteger selectedRow;

/**
 * All gesture components
 */
@property (getter=getGestureComponents, nonatomic) NSArray *allGestureComponents;

/**
 * Determine whether tableView is in editing mode or not
 */
@property (getter=getIsOnEdit, nonatomic) BOOL isOnEdit;

/**
 * YES to make tableView interactable otherwise NO
 */
@property (setter=setInteractionEnable:, nonatomic) BOOL interactionEnable;

/**
 * Return last expand parent index otherwise negative value
 */
@property (getter=getLastExpandParentIndex, nonatomic) NSInteger lastExpandParentIndex;

/**
 * Collapse all parent cells
 */
- (void)collapseAllRows;

/**
 * Exapnd a parent cell
 */
- (BOOL)expandForParentCellAtIndex:(NSInteger)index;

/**
 * Return YES if parent cell at index can be expanded otherwise NO
 */
- (BOOL)canExpandParentCellAtIndex:(NSInteger)index;

/**
 * Return a new tableView cell that was designed in xib
 */
- (UITableViewCell *)cellViewFromNib:(NSString *)nibName atViewIndex:(NSUInteger)viewIndex;

/**
 * Add listener and listen UIScrollViewDelegate event
 * If you add listener then you are responsible to remove
 * when no longer want to listen event
 */
- (void)addListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener;

/**
 * Remove listener for UIScrollViewDelegate event
 */
- (void)removeListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener;

/**
 * Add gesture component
 */
- (void)addGestureComponent:(GestureComponent *)component;

/**
 * Remove gesture component
 */
- (void)removeGestureComponent:(GestureComponent *)component;

/**
 * Remove gesture component by class
 */
- (void)removeGestureComponentByClass:(Class)componentClass;

/**
 * Find gesture Component by class
 */
- (id)findGestureComponentByClass:(Class)componentClass;

/**
 * Return parent cell if found otherwise nil
 */
- (ParentTableViewCell *)findCellByTouchPoint:(CGPoint)point;

/**
 * Insert new parent cell at index
 * You must insert new data into your data source before calling this method
 */
- (void)insertNewRowAtIndex:(NSInteger)index withAnimation:(UITableViewRowAnimation)anim;

/**
 * Delete parent cell at index
 * You must delete data from your data source before calling this method
 */
- (void)deleteRowAtIndex:(NSInteger)index withAnimation:(UITableViewRowAnimation)anim;

- (void)moveRowAtIndex:(NSInteger)targetIndex toIndex:(NSInteger)destIndex;

@end
