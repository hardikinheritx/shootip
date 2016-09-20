//
//  CaptureVideoVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPostVC.h"
#import "SCRecorder.h"
#import "SCRecordSessionManager.h"
#import "MBCircularProgressBarView.h"
#import "SCRecorderTools.h"

@interface CaptureVideoVC : UIViewController<SCRecorderDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVAudioPlayerDelegate>
{
    IBOutlet UIView *cameraView;
    
    IBOutlet MBCircularProgressBarView *progressView;
    IBOutlet UIView *InfoView;
    IBOutlet UIButton *btnCapture;
    IBOutlet UIButton *btnGallery;
}
- (IBAction)actionCapture:(id)sender;
- (IBAction)actionCloseCamera:(id)sender;

@end
