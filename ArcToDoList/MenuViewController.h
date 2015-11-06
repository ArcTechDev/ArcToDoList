//
//  MenuViewController.h
//  ArcToDoList
//
//  Created by User on 6/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>

@optional
- (void)onProfileSelected;
- (void)onColorSelected;
- (void)onPrivacySelected;
- (void)onLanguageSelected;
- (void)onNotificationSelected;

@end

@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<MenuViewControllerDelegate> delegate;

@end
