





#import "UIView_Subclass.h"

@implementation UIView_Subclass

-(void)setBorderColor:(UIColor *)borderColor
{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    [self.layer setCornerRadius:cornerRadius];
}

-(void)setShadowColor:(UIColor *)shadowColor
{
    [self.layer setShadowColor:shadowColor.CGColor];
}
-(void)setShadowOffset:(CGSize)shadowOffset
{
    [self.layer setShadowOffset:shadowOffset];

}
-(void)setShadowOpacity:(CGFloat)shadowOpacity
{
    [self.layer setShadowOpacity:shadowOpacity];
}
-(void)setShadowPath:(CGPathRef)shadowPath
{
        [self.layer setShadowPath:shadowPath];

}
-(void)setShadowRadius:(CGFloat)shadowRadius
{
    
    [self.layer setShadowRadius:shadowRadius];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
