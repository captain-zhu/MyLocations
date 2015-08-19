//
//  CurrentLocationViewController.h
//  MyLocations
//
//  Created by zhu yongxuan on 15/8/11.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//


@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *adressLabel;
@property (nonatomic, weak) IBOutlet UIButton *tagButton;
@property (nonatomic, weak) IBOutlet UIButton *getButton;


- (IBAction)getLocaltion:(id)sender;

@end

