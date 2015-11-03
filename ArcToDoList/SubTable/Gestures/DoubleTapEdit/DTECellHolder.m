//
//  DTECellHolder.m
//  SubTableView
//
//  Created by User on 28/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "DTECellHolder.h"

@interface DTECellHolder ()

@property (weak, nonatomic) IBOutlet UITextField *editableTextField;

@end

@implementation DTECellHolder

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
    
    CGRect toRect = self.frame;
    self.frame = CGRectMake(toRect.origin.x, toRect.origin.y - toRect.size.height, toRect.size.width, toRect.size.height);
    
    [UIView animateWithDuration:0.5f animations:^{
    
        self.frame = toRect;
        
    } completion:^(BOOL finished){
    
        if(finished){
            
            [_editableTextField becomeFirstResponder];
        }
    }];
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
