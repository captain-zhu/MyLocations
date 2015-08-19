//
//  LocationDetailViewController.h
//  MyLocations
//
//  Created by zhu yongxuan on 15/8/17.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailViewController : UITableViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;

@end
