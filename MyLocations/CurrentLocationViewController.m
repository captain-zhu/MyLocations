//
//  CurrentLocationViewController.m
//  MyLocations
//
//  Created by zhu yongxuan on 15/8/11.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController
{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeccoding;
    NSError *_lastReverseError;
}

#pragma mark - App lifecycle methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _locationManager = [[CLLocationManager alloc] init];
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabels];
    [self configureGetButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom methods

/**
 *  获取地址
 */
- (IBAction)getLocaltion:(id)sender
{
    //ios8后需要想要请求许可
    int authorizationStatus =[CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
        return;
    }
    
    
    _locationManager.delegate = self;
    
    // 如果未被许可，向用户发出对应信息，并请求用户的许可
    if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusDenied) {
        [self showLocationServicesDeniedAlert];
        return;
    }
    
    if (_updatingLocation) {
        [self stopLocationManager];
    } else {
        [self startLocationManager];
        _location = nil;
        _lastLocationError = nil;
        _placemark = nil;
        _lastReverseError = nil;
    }
    
    [self updateLabels];
    [self configureGetButton];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        LocationDetailViewController *controller = navigationController.topViewController;
        
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
        controller.manageObjectContext = self.manageObjectContext;
    }
}

/**
 *  向用户发出定位服务被拒绝的信息
 */
- (void)showLocationServicesDeniedAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Sevices Disabled"
                                                                         message:@"Please enable location services for this app in Settings."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
   
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  更新标签
 */
- (void)updateLabels
{
    
    if (_location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%0.8f", _location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%0.8f", _location.coordinate.longitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @"";
        if (_placemark != nil) {
            self.adressLabel.text = [self stringFromPlacemark:_placemark];
        } else if (_performingReverseGeccoding) {
            self.adressLabel.text = @"Searching for address...";
        } else if (_lastReverseError != nil) {
            self.adressLabel.text = @"Error Fingding address";
        } else {
            self.adressLabel.text = @"No address found";
        }
    } else {
        self.longitudeLabel.text = @"";
        self.latitudeLabel.text = @"";
        self.adressLabel.text = @"";
        self.tagButton.hidden = YES;
        
        NSString *statusMessage;
        
        //出现错误，标题栏显示相应信息
        if (_lastLocationError != nil) {
            NSError *error = _lastLocationError;
            if ([error.domain isEqualToString: kCLErrorDomain] && error.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disable"; //用户未许可定位服务
            } else {
                statusMessage = @"Error Getting Location"; //其他错误
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Service Disable"; //定位服务不可用
        } else if (_updatingLocation) {
            statusMessage = @"Searching..."; // 正在搜索中
        } else {
            statusMessage = @"Prees the Button to Start";
        }
        
        self.messageLabel.text = statusMessage;
        
    }
}

/**
 *  启动定位管理器
 */
- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters; //设置定位精度为10米
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

/**
 *  停止定位管理器
 */
- (void)stopLocationManager
{
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ditTimeOut:) object:nil];
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

/**
 *  确定获取按钮的状态并显示相应内容
 */
- (void)configureGetButton
{
    if (_updatingLocation) {
        [self.getButton setTitle:@"停止" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:@"获取地址" forState:UIControlStateNormal];
    }
}

/**
 *  生产由placemark得出的地址的字符串
 */
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", thePlacemark.subThoroughfare,
            thePlacemark.thoroughfare, thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"xxx Time is out");
    
    if (_location == nil) {
        [self stopLocationManager];
        
        _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
        [self configureGetButton];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"是否出错 %@", error);
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
    
    [self updateLabels];
    [self configureGetButton];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"更新的新地址是 %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
      
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
        NSLog(@"We ar done");
        [self stopLocationManager];
        [self configureGetButton];
        }
        
        if (distance > 0) {
            _performingReverseGeccoding = NO;
        }
        
        // 解析地址
        if (!_performingReverseGeccoding) {
            NSLog(@"XXX Going to geocode");
            
            _performingReverseGeccoding = YES;
            
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"*** Found placesmarks: %@, error: %@", placemarks, error);
                
                _lastReverseError = error;
                if (error == nil && [placemarks count] > 0) {
                    _placemark = [placemarks lastObject];
                } else {
                    _placemark = nil;
                }
                
                _performingReverseGeccoding = NO;
                [self updateLabels];
            }];
            
        }
        
        else if (distance < 1.0) {
            NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:newLocation.timestamp];
            if (timeInterval > 10) {
                NSLog(@"xxx Force Done");
                
                [self stopLocationManager];
                [self updateLabels];
                [self configureGetButton];
            }
        }
    }
    
    
}






































@end
