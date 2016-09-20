//
//  DXAnnotationView.m
//  CustomCallout
//
//  Created by Selvin on 05/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"
#import "CustomAnnotationView.h"

#define kfltpoint25 0.25
#define kflt1 1.0
#define kflt2 2.0
#define kflt10 10.0
#define kflt60 60.0

@interface DXAnnotationView () {
    BOOL _hasCalloutView;
}

@property(nonatomic, strong) DXAnnotationSettings *settings;

@end

@implementation DXAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier
                           pinView:(UIView *)pinView
                       calloutView:(CustomAnnotationView *)calloutView
                          settings:(DXAnnotationSettings *)settings
{
    NSAssert(pinView != nil, @"Pinview can not be nil");
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = NO;
        [self validateSettings:settings];
        _hasCalloutView = (calloutView) ? YES : NO;
        self.canShowCallout = NO;

        self.pinView = pinView;
        self.pinView.userInteractionEnabled = YES;
        self.calloutView = calloutView;
        self.calloutView.hidden = YES;
        [self addSubview:self.pinView];
        [self addSubview:self.calloutView];
        self.frame = [self calculateFrame];
        if (_hasCalloutView) {
            if (self.settings.shouldAddCalloutBorder) {
                [self addCalloutBorder];
            }
            if (self.settings.shouldRoundifyCallout) {
                [self roundifyCallout];
            }
        }
        [self positionSubviews];
//        UILabel *lblSeessionCount  = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x +15, self.frame.origin.y - 10, self.frame.size.width, self.frame.size.height)];
//        lblSeessionCount.text = @"10";
//        [self addSubview:lblSeessionCount];
        
    }
    return self;
}

- (CGRect)calculateFrame
{
    return self.pinView.bounds;
}

- (void)positionSubviews {
    self.pinView.center = self.center;
    if (_hasCalloutView) {
        CGRect frame = self.calloutView.frame;
        frame.origin.y = -frame.size.height - self.settings.calloutOffset + kflt10;
        frame.origin.x = ((self.frame.size.width - frame.size.width) / kflt2) + kflt60;
        self.calloutView.frame = frame;
    }
}

- (void)roundifyCallout {
    self.calloutView.layer.cornerRadius = self.settings.calloutCornerRadius;
}

- (void)addCalloutBorder {
    self.calloutView.layer.borderWidth = self.settings.calloutBorderWidth;
    self.calloutView.layer.borderColor = self.settings.calloutBorderColor.CGColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_hasCalloutView) {
        UITouch *touch = [touches anyObject];
        // toggle visibility
        if (touch.view == self.pinView) {
            if (self.calloutView.isHidden) {
                [self showCalloutView];
            } else {
                [self hideCalloutView];
            }
        } else if (touch.view == self.calloutView) {
            [self showCalloutView];
        } else {
            [self hideCalloutView];
            [self CustomDelegateMethodCall];
        }
    }
}

- (void)hideCalloutView
{
    if (_hasCalloutView)
    {
        if (!self.calloutView.isHidden)
        {
            switch (self.settings.animationType)
            {
            case DXCalloutAnimationNone: {
                self.calloutView.hidden = YES;
            } break;
            case DXCalloutAnimationZoomIn: {
                self.calloutView.hidden = YES;
//                self.calloutView.transform = CGAffineTransformMakeScale(kflt1, kflt1);
//                [UIView animateWithDuration:self.settings.animationDuration animations:^{
//                    self.calloutView.transform = CGAffineTransformMakeScale(kfltpoint25, kfltpoint25);
//                } completion:^(BOOL finished) {
//                    self.calloutView.hidden = YES;
//                }];
            } break;
            case DXCalloutAnimationFadeIn: {
                self.calloutView.hidden = YES;
//                self.calloutView.alpha = kflt1;
//                [UIView animateWithDuration:self.settings.animationDuration animations:^{
//                    self.calloutView.alpha = 0.0;
//                } completion:^(BOOL finished) {
//                    self.calloutView.hidden = YES;
//                }];
            } break;
            default: {
                self.calloutView.hidden = YES;
            } break;
            }
        }
    }
}

- (void)showCalloutView {
    if (_hasCalloutView) {
        if (self.calloutView.isHidden) {
            switch (self.settings.animationType) {
            case DXCalloutAnimationNone: {
                self.calloutView.hidden = NO;
            } break;
            case DXCalloutAnimationZoomIn: {
                self.calloutView.transform = CGAffineTransformMakeScale(0.025, kfltpoint25);
                self.calloutView.hidden = NO;
                [UIView animateWithDuration:self.settings.animationDuration animations:^{
                    self.calloutView.transform = CGAffineTransformMakeScale(kflt1, kflt1);
                } completion:nil];
            } break;
            case DXCalloutAnimationFadeIn: {
                self.calloutView.alpha = 0.0;
                self.calloutView.hidden = NO;
                [UIView animateWithDuration:self.settings.animationDuration animations:^{
                    self.calloutView.alpha = kflt1;
                } completion:nil];
            } break;
            default: {
                self.calloutView.hidden = NO;
            } break;
            }
        }
    }
}

#pragma mark - validate settings -

- (void)validateSettings:(DXAnnotationSettings *)settings {
    NSAssert(settings.calloutOffset >= 5.0, @"settings.calloutOffset should be atleast 5.0");
    if (settings.shouldRoundifyCallout) {
        NSAssert(settings.calloutCornerRadius >= 3.0, @"settings.calloutCornerRadius should be atleast 3.0");
    }

    if (settings.shouldAddCalloutBorder) {
        NSAssert(settings.calloutBorderColor != nil, @"settings.calloutBorderColor can not be nil");
        NSAssert(settings.calloutBorderWidth >= kflt1, @"settings.calloutBorderWidth should be atleast 1.0");
    }

    if (settings.animationType != DXCalloutAnimationNone) {
        NSAssert(settings.animationDuration > 0.0, @"settings.animationDuration should be greater than zero");
    }

    self.settings = settings;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return nil;
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isCallout = (CGRectContainsPoint(self.calloutView.frame, point));
    BOOL isPin = (CGRectContainsPoint(self.pinView.frame, point));
    return isCallout || isPin;
}

#pragma mark - PinView

- (void)setPinView:(UIView *)pinView {
    //Removing old pinView
    [_pinView removeFromSuperview];
    
    //Adding new pinView to the view's hierachy
    _pinView = pinView;
    [self addSubview:_pinView];
    
    //Position the new pinView
    self.frame = [self calculateFrame];
    self.pinView.center = self.center;
}

- (void)setCalloutView:(CustomAnnotationView *)calloutView {
    //Removing old calloutView
    [_calloutView removeFromSuperview];
    
    //Adding new calloutView to the view's hierachy
    _calloutView = calloutView;
    [self addSubview:_calloutView];
    
    self.calloutView.hidden = YES;
    
    //Adding Border
    if (_hasCalloutView) {
        if (self.settings.shouldAddCalloutBorder) {
            [self addCalloutBorder];
        }
        if (self.settings.shouldRoundifyCallout) {
            [self roundifyCallout];
        }
    }
    [self positionSubviews];
    
}

#pragma mark - For Customview Tapped Method To Move To Detail Page

-(void)CustomDelegateMethodCall
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CustomAnnotationTappedWithId:)])
    {
        [self.delegate CustomAnnotationTappedWithId:self];
    }
}

@end
