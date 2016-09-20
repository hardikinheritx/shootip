//
//  MapVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface MapVC : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIScrollViewDelegate>
{
    MKAnnotationView *annotationView;

}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentMap;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *dictMap;
- (IBAction)actionBack:(id)sender;
- (IBAction)segmentMapTapped:(UISegmentedControl *)sender;
@end
