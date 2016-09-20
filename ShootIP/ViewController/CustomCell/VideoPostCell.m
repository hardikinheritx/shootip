//
//  VideoPostCell.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/19/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "VideoPostCell.h"
#import "HomeVC.h"
@implementation VideoPostCell
@synthesize starView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigureCell:(NSString *)rating postDict:(NSDictionary *)dictPost
{
    
    
    _imgUserProfile.layer.cornerRadius = _imgUserProfile.frame.size.width / 2;
    _imgUserProfile.clipsToBounds = YES;
    _imgUserProfile.layer.borderWidth = 1.5f;
    _imgUserProfile.layer.borderColor = [UIColor whiteColor].CGColor;

    
    starView.starHighlightedImage = [UIImage imageNamed:@"icn_star"];
    
  //  NSInteger Rating = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"Rating"]]integerValue];
    
    starView.maxRating = 5.0;
    starView.delegate = self;
    starView.horizontalMargin = 12;
    starView.editable=NO;
    starView.rating= [rating floatValue];
    starView.displayMode=EDStarRatingDisplayAccurate;
    [starView setTransform:CGAffineTransformMakeRotation(M_PI)];
    starView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(-1, 1), 0);
    

    
    _lblPlaceName.text=[dictPost objectForKey:@"place"];
    _lblNoOfComment.text=[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"total_comments"]];
    _lblNoOfLike.text=[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"total_likes"]];
    _lblNoOfVideoShared.text=[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"video_added_count"]];
    _lblDescription.text=[dictPost objectForKey:@"post_description"];
    
   _lblPostCreatedDateAndTime.text=[NSString stringWithFormat:@"%@",[APPDELEGATE UTCtoDeviceTimeZone:[dictPost objectForKey:@"created_at"]]];
    
    NSString *likePost=[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"likebyme"]];
    
    if([likePost isEqualToString:@"1"])
    {
        [_btnImgLikeDislike setSelected:YES];
    }
    else
    {
        [_btnImgLikeDislike setSelected:NO];
    }
    
    if([[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]] isEqualToString:[NSString stringWithFormat:@"%@",[[dictPost objectForKey:@"user_data"] objectForKey:KEYUSERID]]])
    {
        [_btnReportOrEdit setImage:[UIImage imageNamed:@"icn_edit.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnReportOrEdit setImage:[UIImage imageNamed:@"icn_other.png"] forState:UIControlStateNormal];
    }
    
    
   _lblUserName.text=[[dictPost objectForKey:@"user_data"] objectForKey:KEYUSERNAME];

    
    NSURLRequest *userProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[dictPost objectForKey:@"user_data"] objectForKey:@"user_image"]]];
    UIImage *placeholderImage = [UIImage imageNamed:@"user_placeholder_icon"];
    [_imgUserProfile setupImageViewerWithImageURL:[NSURL URLWithString:[[dictPost objectForKey:@"user_data"] objectForKey:@"user_image"]]];
    
    [_imgUserProfile setImageWithURLRequest:userProfileRequest
                               placeholderImage:placeholderImage
                                        success:nil
                                        failure:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dictPost objectForKey:@"video_thumb"]]];
    [_imgVideoThumbnail setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"logo_placeholder"]
                                           success:nil failure:nil];
    
    
    [_videoActivityIndicator setHidden:YES];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
  //  NSLog(@"bounds = %@", NSStringFromCGRect(_imgVideoThumbnail.frame));

}
-(void)btnMapAction:(UIButton *)sender
{
    NSLog(@"my map tapped %lu",sender.tag);
}
@end
