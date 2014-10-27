//
//  BNViewController.h
//  Beaconator
//
//  Created by Jeffrey Berthiaume on 2/14/14.
//  Copyright (c) 2014 Pushplay.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BNViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, CBPeripheralManagerDelegate> {
    UIButton *doneButton;
    UITextField *activeField;
    BOOL isBroadcasting;
}

@property (nonatomic, weak) IBOutlet UIScrollView *sv;
@property (nonatomic, weak) IBOutlet UIButton *randomizeButton;
@property (nonatomic, weak) IBOutlet UIButton *broadcastButton;
@property (nonatomic, weak) IBOutlet UITextField *identifier;
@property (nonatomic, weak) IBOutlet UITextField *udid;
@property (nonatomic, weak) IBOutlet UITextField *major;
@property (nonatomic, weak) IBOutlet UITextField *minor;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;


@end
