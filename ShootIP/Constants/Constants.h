

#pragma mark - Device Detection -
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ]  || [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ])
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPAD   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )
#define iPhone5  ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define iPhone4  ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define iPhone6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)
#define iPhone6Plus ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 736)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define iPhone5Landscape  ([[UIScreen mainScreen] bounds].size.width == 568.0f)
#define iPhone4Landscape  ([[UIScreen mainScreen] bounds].size.width == 480.0f)
#define iPhone6Landscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 667)
#define iPhone6PlusLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 736)

#define iOS7 if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define SCREEENWIDTH (self.view.frame.size.width>self.view.frame.size.height)?self.view.frame.size.width:self.view.frame.size.height

#define BASEURL @"http://52.36.94.32/api/web/"
//#define BASEURL @"http://inheritxdev.net/shootip/api/web/"
//#define BASEURL @"http://shootip.inheritxserver.com/api/web/"


#define APPNAME @"Shootip"

#define FILEMANAGER [NSFileManager defaultManager]

#define APPDELEGATE (AppDelegate*)[UIApplication sharedApplication].delegate

#define USERDEFAULTS [NSUserDefaults standardUserDefaults]

#define DEFAULTTIMEOUT 180.0


#define KLATITUDEDISTANCE 2500
#define KLONGITUDEDISTANCE 2500
#define DefaultProfileImageSize CGSizeMake(90, 90)


#pragma mark ALERT MESGS

#define ALERT_OK @"OK"
#define ALERT_CANCEL @"Cancel"
#define ALERTIMAGE @"Please add photo."
#define ALERTUSERNAMEBLANK @"Please enter username."
#define ALERTNAMEBLANK @"Please Enter your name"
#define ALERTINVALIDEMAIL @"Please enter valid email address."
#define ALERTEMAILBLANK @"Please enter email address."
#define ALERTPASSWORDBLANK @"Please enter password."
#define ALERTOLDPASSWORDBLANK @"Please enter old password."
#define ALERTNEWPASSWORDBLANK @"Please enter new password."
#define ALERTRETYPEPASSWORDBLANK @"Please enter confirm password."
#define ALERTPASSWORDMISMATCH @"Password and confirm password must be same."
#define ALERTSMALLPASSWORD @"Please enter at least 6 character password."

#define ALERT_SELECT_PROFILE_PIC @"Select Profile Picture"
#define ALERT_CAMERA @"Camera"
#define ALERT_SELECT_FROM_GALLERY @"Select from Gallery"
#define ALERT_CAMERA_UNAVAILABLE @"Camera is not available on simulator"
#define ALERTINFO @"Will be delivered in upcoming milestones."

#define kRequestFailed @"Request processing failed. Please try again later."

#define APILOGIN @"users/login"
#define APIVERIFYUSERNAME @"users/verify-username"
#define APISIGNUP @"users/sign-up"
#define APICHANGEPASSWORD @"users/change-password"
#define APIFORGOTPASSWORD @"users/forgot-password"
#define APILISTOFPOST @"posts/list-of-post"
#define APIAROUNDME @"posts/list-of-nearby-post"
#define APICREATEALBUM @"albums/create-album"
#define APILISTOFALBUM @"albums/list-of-albums"
#define APICREATEPOST @"posts/create-post"
#define APILIKEDISLIKEPOSTALBUM @"users/like-dislike-post-album"
#define APIADDVIDEOTOALBUM @"albums/add-video-to-album"
#define APIREPORTABUSE @"posts/report-abuse-post"
#define APILISTOFCATEGORY @"posts/get-all-post-categories"
#define APILISTOFPOSTBYPLACE @"posts/list-of-posts-by-place"

#define APIGETALLCOMMENT_POST @"posts/get-all-post-comments"
#define APIGETALLCOMMENT_ALBUM @"albums/get-all-album-comments"

#define APIADDCOMMENT_ALBUM @"albums/add-album-comments"
#define APIADDCOMMENT_POST @"posts/add-post-comments"


#define APIGETRECENTPLACES @"posts/get-recent-places"

#define APIDELETEPOST @"posts/delete-post"
#define APIEDITPOST @"posts/edit-post"
#define APIFOLLOWUNFOLLOWPLACE @"posts/follow-unfollow-place"
#define APILISTOFFOLLOWPLACE @"posts/get-list-of-place-followed-by-user"

#define APIUSERDETAILS @"users/user-details"
#define APILISTOFPOSTBYCITY @"posts/list-of-posts-by-city"

#define APIEDITPROFILE @"users/edit-profile"
#define APILISTOFALBUMBYVIDEO @"albums/list-of-video-by-album"
#define APILISTOFVIDEOBYSEARCHALBUM @"albums/list-of-video-by-album-search"


#define APIDELETEALBUM @"albums/delete-album"
#define APISEARCH @"albums/search-by-place-album-hashtag"
#define APINOTIFICATIONLIST @"users/get-notification-list-for-user"
#define APILISTOFPOSTBYHASHTAG @"posts/list-of-posts-by-hash-tag"



#define UPDATECOMMENTCOUNTNOTIFICATION @"UpdateCommentCountNotiifcaion"


#define KEYPOSTID @"post_id"

#define KEYTOTALCOMMENTS @"total_comments"

#define kThemeRedColor [UIColor colorWithRed:(float)230/255 green:(float)107/255 blue:(float)89/255 alpha:1]
#define kThemeBlueColor [UIColor colorWithRed:(float)80/255 green:(float)130/255 blue:(float)176/255 alpha:1]

// Tableview Cells For iPhone6, iPhone6 Plus Support
#define kVerticalGap 5
#define kHorizantalBattleCompareCellPadding 32
#define kHorizantalSingleCellPadding 26


#define STORYBOARD [UIStoryboard storyboardWithName:@"MainApplication" bundle:nil]

#define KEYDEVICETOKEN @"iphone_device_token"
#define KEYAUTHTOKEN @"auth_token"
#define KEYUSERID @"user_id"
#define KEYUSERNAME @"username" 
#define KEYLOGGEDIN @"isLoggedIn"
#define KEYPAGEINDEX @"page_index"

#define KEYISFBUSER @"is_facebook_user"

#define KEYPOSTID @"post_id"
#define KEYALBUMID @"album_id"
#define KEYCOMMENTTEXT @"comment_text"

#define KEYISPOSTUPDATED @"isPostUpdated"

// Resume video in play all
//#define KEYRESUMEFROMCOUNT @"resumecount"
#define KEYSHOOTIPVIDEOFOLDER @"shootip"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Constants : NSObject

+(BOOL) validateEmail: (NSString *) candidate;
+(NSString*)myUserID;
+(void)placeholdercolorchange:(UITextField *)textFeild;
+(void)setTextFieldPadding:(UITextField *)textField paddingValue:(float)padding;
+(NSString*)getDocumentDirectoryPath;
+(void)RemoveVideoFromDocumentDirectory:(NSString *)VideoName;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image andMaxResolution:(int) maxSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end