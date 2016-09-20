//
//  MapVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "MapVC.h"
#import "MKMapView+ZoomLevel.h"

@interface MapVC ()
{
    MKPointAnnotation *annotationPoint;
    MKCoordinateRegion mapRegion;
}

@end

@implementation MapVC
@synthesize mapView;
@synthesize dictMap;

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView.delegate =self;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude=[[dictMap objectForKey:@"latitude"] floatValue];
    annotationCoord.longitude=[[dictMap objectForKey:@"longitude"] floatValue];
    annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title =[dictMap objectForKey:@"place"];
//    annotationPoint.subtitle =@"Description";
    [mapView addAnnotation:annotationPoint];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(annotationPoint.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
    mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Map Screen"];
    [APPDELEGATE setDropOffScreen:@"Map Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}
#pragma mark - Action Method -

- (IBAction)segmentMapTapped:(UISegmentedControl *)sender
{
    switch (((UISegmentedControl *) sender).selectedSegmentIndex)
    {
        case 0:
            [mapView setMapType:MKMapTypeStandard];
            break;
            
        case 1:
            [mapView setMapType:MKMapTypeSatellite];
            break;
    }
}

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -MapViewAnnotation Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"loc"];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"] ;
    }
    
    if(annotation == self.mapView.userLocation)
    {
        //        annotationView.image = [UIImage imageNamed:@"icn_map_pin"];
        //        annotationView.canShowCallout=NO;
        return nil;
    }
    annotationView.canShowCallout = YES;
//    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.image = [UIImage imageNamed:@"icn_mapPin"];
    return annotationView;
}
-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
    
}
- (void)mapView:(MKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Zoom level %f",[mapView zoomLevel]);
    //    // Constrain zoom level to 8.
    if( [mapView zoomLevel] > 17.5 )
    {
      
                        [mapView setCenterCoordinate:mapView.centerCoordinate
                                           zoomLevel:17.8
                                            animated:YES];

    
    }
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
