//
//  AddLocationVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "AddLocationVC.h"
#import "SelectPlacesTableViewCell.h"
#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"
#import "CustomAnnotationView.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "RecentPlaces.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "MKMapView+ZoomLevel.h"

@interface Annotation : NSObject <MKAnnotation>

@property(nonatomic, assign)CLLocationCoordinate2D coordinate;

@end

@implementation Annotation

@end


@interface AddLocationVC ()
{
    NSMutableArray *arrRecentPlaces;
}
@end

@implementation AddLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    _mapView.showsUserLocation = YES;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGesture:)];
    tapGesture.numberOfTapsRequired = 1.0;
    [_mapView addGestureRecognizer:tapGesture];
    _mapView.showsUserLocation = YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self callWebservice];
    _objRecentPlace = [[RecentPlaces alloc]init];
    arrRecentPlaces= [[NSMutableArray alloc]init];
    
    
    _tblRecentPlace.rowHeight = UITableViewAutomaticDimension;
    
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
    searchQuery.radius = 200.0;
    [_txtSearchBar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _tblSearchBar.rowHeight = UITableViewAutomaticDimension;
    
    if (_objSelectedRecentPlace)
    {
        _objRecentPlace = _objSelectedRecentPlace;
        
        
        [_mapView removeAnnotations:_mapView.annotations];
        Annotation *annotation = [Annotation new];
        annotation.coordinate = _objRecentPlace.coorDinate;
        [_mapView addAnnotation:annotation];
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
    }
    else{
        
        
        CLLocationDegrees latitude = [[APPDELEGATE strLatitude] floatValue];
        CLLocationDegrees longitude = [[APPDELEGATE strLongitude] floatValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self reverseGeocode:location];

        
//                        Annotation *annotation = [Annotation new];
//                            CLLocationCoordinate2D coorDinate=CLLocationCoordinate2DMake([[APPDELEGATE strLatitude] floatValue],[[APPDELEGATE strLongitude] floatValue]);
//                            annotation.coordinate = coorDinate;
//        
//                            [_mapView addAnnotation:annotation];
//                            [_mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add Location Screen"];
    [APPDELEGATE setDropOffScreen:@"Add Location Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - TextField Delegate

-(void)textFieldDidChange:(UITextField *)theTextField
{
    if (_txtSearchBar.text.length>0)
    {
        viewSearchBar.hidden = NO;
        _mapView.userInteractionEnabled=NO;
    }
    else
    {
        viewSearchBar.hidden = YES;
        _mapView.userInteractionEnabled=YES;
    }
    NSLog(@"textField.text is %@",theTextField.text);
    

    searchQuery.input = theTextField.text;
//    searchQuery.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error)
        {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        }
        else
        {
            ViewForNoPlace.hidden = YES ;
            arrSearchResult = [[NSMutableArray alloc]initWithArray:places];
            [_tblSearchBar reloadData];
        }
    }];
}


#pragma mark - SPGooglePlacesAutoCompletePlace Delegate -

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath
{
    return [arrSearchResult objectAtIndex:indexPath.row];
}


#pragma mark - Gesture methods -

-(void)TapGesture:(UIGestureRecognizer *)objGesture
{
    [self.view endEditing:YES];
    viewSearchBar.hidden=YES;
    _mapView.userInteractionEnabled=YES;
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender
{
    // This is important if you only want to receive one tap and hold event
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        //[self.mapView removeGestureRecognizer:sender];
    }
    else
    {
        // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
        [SVProgressHUD show];
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        //NSString *strAddress =  [self getAddressFromLatLon:locCoord.latitude withLongitude:locCoord.longitude];
        
        CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:locCoord.latitude longitude:locCoord.longitude];
        _objRecentPlace.strName=@"";
        [self reverseGeocode:LocationAtual];
    }
}
#pragma mark - location methods -

-(void)placeFavouritePlace:(NSDictionary *)dictAddress withCoorDinate:(CLLocationCoordinate2D)objCoordinate
{
    [_mapView removeAnnotations:_mapView.annotations];
    NSMutableArray *arrTemp = [dictAddress objectForKey:@"FormattedAddressLines"];
    NSString *strAddress = [arrTemp componentsJoinedByString:@", "];

    if ([_objRecentPlace.strName length]==0) {
    _objRecentPlace.strName = [dictAddress objectForKey:@"Name"];
    }
    _objRecentPlace.strAddress = strAddress;
    _objRecentPlace.strLatitude = [NSString stringWithFormat:@"%f",objCoordinate.latitude];
    _objRecentPlace.strLongitude = [NSString stringWithFormat:@"%f",objCoordinate.longitude];
    _objRecentPlace.coorDinate = objCoordinate;
    
    if ([_objRecentPlace.strCity length]==0)
    {
        
        if ([dictAddress objectForKey:@"City"]) {
            _objRecentPlace.strCity  = [dictAddress objectForKey:@"City"];
         }
        else{
            _objRecentPlace.strCity  = [dictAddress objectForKey:@"SubAdministrativeArea"];
        }
    }
    if ([_objRecentPlace.strState length]==0) {
        _objRecentPlace.strState= [dictAddress objectForKey:@"State"];
    }
    if ([_objRecentPlace.strCountry length]==0) {
        _objRecentPlace.strCountry = [dictAddress objectForKey:@"Country"];
    }
//    _objRecentPlace.strCity   = [dictAddress objectForKey:@"City"];
//    _objRecentPlace.strState= [dictAddress objectForKey:@"State"];
//    _objRecentPlace.strCountry = [dictAddress objectForKey:@"Country"];
    
    Annotation *annotation = [Annotation new];
    annotation.coordinate = _objRecentPlace.coorDinate;
    [_mapView addAnnotation:annotation];
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
    
}
- (IBAction)showCurrentLocation {
    
    _objRecentPlace = [[RecentPlaces alloc]init];

    CLLocationDegrees latitude = [[APPDELEGATE strLatitude] floatValue];
    CLLocationDegrees longitude = [[APPDELEGATE strLongitude] floatValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self reverseGeocode:location];

    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
}
- (void)reverseGeocode:(CLLocation *)location {
    
    
   [SVProgressHUD show];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            [self recenterMapToPlacemark:placemark];
//            NSLog(@"%@",placemark.addressDictionary);
           [self placeFavouritePlace:placemark.addressDictionary withCoorDinate:location.coordinate];
        }
        [SVProgressHUD dismiss];
    }];
    

}
- (void)resolveEstablishmentPlaceToPlacemark:(NSString *)strReference {
    //    SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] initWithApiKey:kGoogleAPIKey];
    
    SPGooglePlacesPlaceDetailQuery *query =[[SPGooglePlacesPlaceDetailQuery alloc] init];
    query.reference = strReference;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            
            NSLog(@"error %@",[error localizedDescription]);
        } else {
            CLLocationDegrees latitude = [placeDictionary[@"geometry"][@"location"][@"lat"] floatValue];
            CLLocationDegrees longitude = [placeDictionary[@"geometry"][@"location"][@"lng"] floatValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [self reverseGeocode:location];
            
        }
    }];
}
- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    //  [self.mapView removeAnnotation:_mapView.annotations];
    Annotation *annotation = [Annotation new];
    annotation.coordinate = _objRecentPlace.coorDinate;
    [_mapView addAnnotation:annotation];
    
    //    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    //    selectedPlaceAnnotation.title = address;
    //    [self.mapView addAnnotation:selectedPlaceAnnotation];
}


#pragma mark - WebService

-(void)callWebservice
{
    NSMutableDictionary *dictFavouritePlace = [[NSMutableDictionary alloc]init];
    [dictFavouritePlace setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictFavouritePlace setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [SVProgressHUD show];
    
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIGETRECENTPLACES method:@"POST" data:dictFavouritePlace withImages:nil withVideo:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mapview Delegates

- (void)mapView:(MKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Zoom level %f",[mapView1 zoomLevel]);
    //    // Constrain zoom level to 8.
    if( [mapView1 zoomLevel] > 17.5 )
    {
        [mapView1 setCenterCoordinate:mapView1.centerCoordinate
                           zoomLevel:17.8
                            animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Annotation class]])
    {
        UIImageView *pinView = nil;
        
        CustomAnnotationView *calloutView = nil;
        
        DXAnnotationView *annotationView = (DXAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];
        annotationView = nil;
        pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_mapPin"]];
        calloutView = [[[NSBundle mainBundle] loadNibNamed:@"CustomAnnotationViewController" owner:self options:nil] firstObject];
        calloutView.lblAddressView.hidden = NO;
        calloutView.lblAddress.text = [NSString stringWithFormat:@"%@,%@",_objRecentPlace.strName,_objRecentPlace.strAddress];
            //    [calloutView.lblAddress sizeToFit];
        annotationView = [[DXAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                              pinView:pinView
                                                          calloutView:calloutView
                                                             settings:[DXAnnotationSettings defaultSettings]];
        calloutView.hidden =NO;
        annotationView.draggable = YES; // Right here baby!

        return annotationView;
    }
//    else {
////        MKAnnotationView *userLocationView = [self.mapView viewForAnnotation:annotation];
////        userLocationView.canShowCallout = NO;
//    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if ([annotationView.annotation isKindOfClass:[Annotation class]])
    {
        if (newState == MKAnnotationViewDragStateEnding)
        {
            CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
            NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
            CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
            _objRecentPlace.strName=@"";
            [self reverseGeocode:LocationAtual];
            
            annotationView.dragState = MKAnnotationViewDragStateNone;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[DXAnnotationView class]])
    {
        DXAnnotationView *annotationView = ((DXAnnotationView *)view);
        if (annotationView.calloutView.hidden)
        {
            annotationView.calloutView.hidden = NO;
        }
        else
        {
            annotationView.calloutView.hidden = YES;
        }
        //        [((DXAnnotationView *)view)hideCalloutView];
        //        view.layer.zPosition = -1;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //    [[self mapView] setCenterCoordinate:view.annotation.coordinate animated:YES];
    if ([view isKindOfClass:[DXAnnotationView class]])
    {
        DXAnnotationView *annotationView = ((DXAnnotationView *)view);
        if (annotationView.calloutView.hidden)
        {
            annotationView.calloutView.hidden = NO;
        }
        else
        {
            annotationView.calloutView.hidden = YES;
        }
        //        [((DXAnnotationView *)view)showCalloutView];
        //        view.layer.zPosition = 0;
    }
}

#pragma mark - TableViewDelegate & Datasource Methods -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tblRecentPlace)
        return arrRecentPlaces.count;
    else
        return [arrSearchResult count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblRecentPlace)
    {
        static NSString *CellIdentifier = @"FavouritePlaceCell";
        SelectPlacesTableViewCell *cellfavouritePlace = (SelectPlacesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cellfavouritePlace == nil)
        {
            cellfavouritePlace = [[SelectPlacesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        RecentPlaces *objRecentPlace = [arrRecentPlaces objectAtIndex:indexPath.row];
        cellfavouritePlace.lblPlaceAddress.text =[NSString stringWithFormat:@"%@, %@",objRecentPlace.strName, objRecentPlace.strAddress];

        return cellfavouritePlace;
    }
    else
    {
        static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
        SelectPlacesTableViewCell *cellfavouritePlace = (SelectPlacesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cellfavouritePlace == nil)
        {
            cellfavouritePlace = [[SelectPlacesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
        
        //         cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
        cellfavouritePlace.lblAddress.text = place.fullAddress;
        
        return cellfavouritePlace;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblRecentPlace)
    {
        [_mapView removeAnnotations:_mapView.annotations];
        _objRecentPlace = [[RecentPlaces alloc]init];

        _objRecentPlace = [arrRecentPlaces objectAtIndex:indexPath.row];
        
        Annotation *annotation = [Annotation new];
        annotation.coordinate = _objRecentPlace.coorDinate;
        [_mapView addAnnotation:annotation];
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
    }
    else
    {
        [tableView setUserInteractionEnabled:NO];
        _objRecentPlace = [[RecentPlaces alloc]init];

        SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
        if ([place.identifier length]==0) {
            [Alerts showAlertWithMessage:@"Location not found. Please select valid locaion." withBlock:nil andButtons:ALERT_OK, nil];
            [tableView setUserInteractionEnabled:YES];
            return;
        }
        
        _objRecentPlace.strName=place.name;
        [self resolveEstablishmentPlaceToPlacemark:place.reference];
        _txtSearchBar.text = @"";
        viewSearchBar.hidden = YES;
        _mapView.userInteractionEnabled=YES;
        [_mapView removeAnnotations:_mapView.annotations];
        [tableView setUserInteractionEnabled:YES];
        [_txtSearchBar resignFirstResponder];
        [SVProgressHUD dismiss];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        //add code here for when you hit delete
//        
//    }
//}


#pragma mark - Action Methods -

- (IBAction)segmentMapTapped:(UISegmentedControl *)sender
{
    switch (((UISegmentedControl *) sender).selectedSegmentIndex)
    {
        case 0:
            [_mapView setMapType:MKMapTypeStandard];
            break;
            
        case 1:
            [_mapView setMapType:MKMapTypeSatellite];
            break;
    }
}
- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveAction:(id)sender {
    
    if (_objRecentPlace)
    {
        [self performSegueWithIdentifier:@"unwindFromAddPlace" sender:self];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
    }
}




#pragma mark - Server connection delegate methods -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
   // NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APIGETRECENTPLACES])
        {
            NSMutableArray *arrFavPlaces = [dictData objectForKey:@"data"];
            [arrRecentPlaces removeAllObjects];
            for (NSMutableDictionary *dictPlace in arrFavPlaces)
            {
                RecentPlaces *objRecentPlace = [[RecentPlaces alloc]init];
                objRecentPlace.strName = [dictPlace objectForKey:@"place"];
                objRecentPlace.strLatitude = [dictPlace objectForKey:@"latitude"];
                objRecentPlace.strLongitude = [dictPlace objectForKey:@"longitude"];
                objRecentPlace.strAddress = [dictPlace objectForKey:@"address"];
                objRecentPlace.strCity = [dictPlace objectForKey:@"city"];
                objRecentPlace.strCountry = [dictPlace objectForKey:@"country"];
                objRecentPlace.coorDinate = CLLocationCoordinate2DMake([objRecentPlace.strLatitude floatValue],[objRecentPlace.strLongitude floatValue]);
                [arrRecentPlaces addObject:objRecentPlace];
            }
            arrRecentPlaces=[[[arrRecentPlaces reverseObjectEnumerator] allObjects] mutableCopy];
            
//            if (!_objSelectedRecentPlace) {
//                
//            
//                if ( [arrRecentPlaces count]>0)
//                {
//                    [_mapView removeAnnotations:_mapView.annotations];
//                    _objRecentPlace = [arrRecentPlaces objectAtIndex:0];
//                    Annotation *annotation = [Annotation new];
//                    
//                    CLLocationCoordinate2D coorDinate=CLLocationCoordinate2DMake([[APPDELEGATE strLatitude] floatValue],[[APPDELEGATE strLongitude] floatValue]);
//                    annotation.coordinate = coorDinate;
//
//                    [_mapView addAnnotation:annotation];
//                    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate,KLATITUDEDISTANCE,KLONGITUDEDISTANCE) animated:YES];
//                }
//            }
        }
            
        [_tblRecentPlace reloadData];
        
            
        
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APIGETRECENTPLACES])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}

@end
