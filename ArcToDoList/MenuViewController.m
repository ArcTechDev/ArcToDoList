//
//  MenuViewController.m
//  ArcToDoList
//
//  Created by User on 6/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuItem.h"
#import "MenuItemCell.h"

@interface MenuViewController ()

@end

@implementation MenuViewController{
    
    NSArray *menuItems;
}

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    menuItems = [NSArray arrayWithObjects:
                 
                 [MenuItem createMenuItemWithTitle:@"Profile" withTarget:self withSelector:@selector(onProfile)],
                 [MenuItem createMenuItemWithTitle:@"Color" withTarget:self withSelector:@selector(onColor)],
                 [MenuItem createMenuItemWithTitle:@"Privacy" withTarget:self withSelector:@selector(onPrivacy)],
                 [MenuItem createMenuItemWithTitle:@"Language" withTarget:self withSelector:@selector(onLanguage)],
                 [MenuItem createMenuItemWithTitle:@"Notification" withTarget:self withSelector:@selector(onNotification)]
                 , nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"MenuItemCell";
    
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(cell == nil){
        
        cell = [[MenuItemCell alloc] init];
    }
    
    MenuItem *item = [menuItems objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = item.title;
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MenuItem *item = [menuItems objectAtIndex:indexPath.row];
    
    [item performAction];
}

#pragma mark - Internal
- (void)onProfile{
    
    if([_delegate respondsToSelector:@selector(onProfileSelected)]){
        
        [_delegate onProfileSelected];
    }
}

- (void)onColor{
    
    if([_delegate respondsToSelector:@selector(onColorSelected)]){
        
        [_delegate onColorSelected];
    }
}

- (void)onPrivacy{
    
    if([_delegate respondsToSelector:@selector(onPrivacySelected)]){
        
        [_delegate onPrivacySelected];
    }
}

- (void)onLanguage{
    
    if([_delegate respondsToSelector:@selector(onLanguageSelected)]){
        
        [_delegate onLanguageSelected];
    }
}

- (void)onNotification{
    
    if([_delegate respondsToSelector:@selector(onNotificationSelected)]){
        
        [_delegate onNotificationSelected];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
