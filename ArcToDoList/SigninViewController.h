//
//  SigninViewController.h
//  ToDoList
//
//  Created by User on 21/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

@class GPPSignInButton;

@interface SigninViewController : UIViewController

@property (retain, nonatomic) IBOutlet GPPSignInButton *googleLogInButton;
@property (retain, nonatomic) IBOutlet FBSDKLoginButton *fbLogInButton;

@end
