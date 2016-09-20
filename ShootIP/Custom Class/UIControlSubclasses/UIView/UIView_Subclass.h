



#import <UIKit/UIKit.h>

@interface UIView_Subclass : UIView
@property (assign,nonatomic) IBInspectable UIColor *borderColor;
@property (assign,nonatomic) IBInspectable CGFloat borderWidth;
@property (assign,nonatomic) IBInspectable CGFloat cornerRadius;



@property (assign,nonatomic) IBInspectable UIColor *shadowColor;
@property (assign,nonatomic) IBInspectable CGSize shadowOffset;
@property (assign,nonatomic) IBInspectable CGFloat shadowOpacity;

@property (assign,nonatomic) IBInspectable CGPathRef *shadowPath;
@property (assign,nonatomic) IBInspectable CGFloat shadowRadius;

@end
