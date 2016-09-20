//
//  AddLocationVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RecentPlaces.h"

@class RecentPlaces;
@class SPGooglePlacesAutocompleteQuery;

@interface AddLocationVC : UIViewController<MKMapViewDelegate>

{
    SPGooglePlacesAutocompleteQuery *searchQuery;
    NSMutableArray *arrSearchResult;
    IBOutlet UIView *viewSearchBar;
    IBOutlet UIView *ViewForNoPlace;
    CLLocationCoordinate2D coordinateCurrent;


}
@property(strong, nonatomic)RecentPlaces *objRecentPlace;

//comming from previous if location is added previously
@property(strong, nonatomic)RecentPlaces *objSelectedRecentPlace;


- (IBAction)btnBackAction:(id)sender;
- (IBAction)btnSaveAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tblSearchBar;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentMap;
@property (strong, nonatomic) IBOutlet UITextField *txtSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *tblRecentPlace;
- (IBAction)segmentMapTapped:(UISegmentedControl *)sender;
@end
