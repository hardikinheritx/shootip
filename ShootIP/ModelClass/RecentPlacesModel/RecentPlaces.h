//
//  RecentPlaces.h
//  ShootIP
//
//  Created by milap kundalia on 1/28/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface RecentPlaces : NSObject
@property(nonatomic,strong)NSString *strAddress;
@property(nonatomic,strong)NSString *strName;
@property(nonatomic,strong)NSString *strLatitude;
@property(nonatomic,strong)NSString *strLongitude;
@property(nonatomic,assign) CLLocationCoordinate2D coorDinate;
@property(nonatomic,strong)NSString *strFavouritePlaceID;
@property(nonatomic,strong)NSString *strCity;
@property(nonatomic,strong)NSString *strState;
@property(nonatomic,strong)NSString *strCountry;


//-latitude
//-longitude
//-place
//-city
//-country
@end
