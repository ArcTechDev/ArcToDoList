//
//  UserInfoViewController.m
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AccountManager.h"

@interface UserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emaillabel;

@end

@implementation UserInfoViewController

@synthesize userPhoto = _userPhoto;
@synthesize userNameLabel = _userNameLabel;
@synthesize emaillabel = _emaillabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UserAccount *account = [AccountManager sharedManager].userAccount;
    
    [account queryProfileImageURLComplete:^(NSString *imageURL){
        
        _userPhoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    
    } Fail:^(NSError *error){
    
        NSLog(@"display photo error %@", error);
    }];
    
    [account queryProfileNameComplete:^(NSString *name){
    
        _userNameLabel.text = name;
        
    } Fail:^(NSError *error){
    
        NSLog(@"display user name error %@", error);
    }];
    
    [account queryProfileEmailComplete:^(NSString *email){
    
        _emaillabel.text = email;
        
    } Fail:^(NSError *error){
    
        NSLog(@"display user email error %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signout:(id)sender{
    
    [[AccountManager sharedManager].userAccount logout];
    
    [self.presentingViewController  dismissViewControllerAnimated:YES completion:nil];
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
