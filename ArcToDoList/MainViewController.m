//
//  MainViewController.m
//  ArcToDoList
//
//  Created by User on 23/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "MainViewController.h"
#import "AccountManager.h"


@interface MainViewController ()

@end

@implementation MainViewController{
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    if([[AccountManager sharedInstance] shouldLogin])
        [self performSegueWithIdentifier:@"Signin" sender:nil];
    else
        [self performSegueWithIdentifier:@"UserInfoFromMain" sender:nil];
     
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
