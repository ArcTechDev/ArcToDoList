//
//  SigninViewController.h
//  ToDoList
//
//  Created by User on 21/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

//#import <FBSDKLoginKit/FBSDKLoginButton.h>

#import <UIKit/UIKit.h>

@class GPPSignInButton;

@interface SigninViewController : UITableViewController<FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (retain, nonatomic) IBOutlet GIDSignInButton *googleLogInButton;
@property (retain, nonatomic) IBOutlet FBSDKLoginButton *fbLogInButton;

@end
