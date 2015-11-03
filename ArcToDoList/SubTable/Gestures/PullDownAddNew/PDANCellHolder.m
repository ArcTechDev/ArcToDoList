//
//  PDANCellHolder.m
//  NPTableView
//
//  Created by User on 20/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "PDANCellHolder.h"

@interface PDANCellHolder ()

@property (weak, nonatomic) IBOutlet UITextField *editableTextField;

@end

@implementation PDANCellHolder

@synthesize editableTextField = _editableTextField;
@synthesize delegate = _delegate;

#pragma mark - public interface
+ (id)CellHolderWithNibName:(NSString *)nibName{

    if(nibName == nil)
        return nil;
    
    if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]){
        
        //get xib file
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        //get view
        UIView *view = [nibContents objectAtIndex:0];
        
        return view;
    }
    
    return nil;
}

- (void)startEdit{
    
    _editableTextField.delegate = self;
    
    _editableTextField.text = @"";
    
    [_editableTextField becomeFirstResponder];
}

- (void)changeItemText:(NSString *)text{
    
    _editableTextField.text = text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [_editableTextField resignFirstResponder];
    
    if([_delegate respondsToSelector:@selector(endEditWithText:)]){
        
        [_delegate endEditWithText:_editableTextField.text];
    }
    
    
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
