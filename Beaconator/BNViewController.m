//
//  BNViewController.m
//  Beaconator
//
//  Created by Jeffrey Berthiaume on 2/14/14.
//  Copyright (c) 2014 Pushplay.net. All rights reserved.
//

#import "BNViewController.h"
#import "Flurry.h"

@interface BNViewController ()

@end

@implementation BNViewController

#pragma mark - View Loading/Unloading

- (void)viewDidLoad
{
    [super viewDidLoad];
    isBroadcasting = NO;
    
    doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    [doneButton setTitle:@"Next" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.randomizeButton.layer.cornerRadius = 5;
    self.broadcastButton.layer.cornerRadius = 62;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *uuid = [defaults objectForKey:@"uuid"];
    NSString *identifier = [defaults objectForKey:@"identifier"];
    NSString *major = [defaults objectForKey:@"major"];
    NSString *minor = [defaults objectForKey:@"minor"];
    
    if (!uuid || [uuid isEqualToString:@""]) {
        [self generateRandomUUID];
    } else {
        self.udid.text = uuid;
    }
    
    if (identifier) {
        self.identifier.text = identifier;
    }
    
    if (major) {
        self.major.text = major;
    }
    
    if (minor) {
        self.minor.text = minor;
    }
    
    self.identifier.delegate = self;
    self.identifier.tag = 1;
    self.udid.delegate = self;
    self.udid.tag = 2;
    self.major.delegate = self;
    self.major.tag = 3;
    self.minor.delegate = self;
    self.minor.tag = 4;
    
    self.sv.contentSize = CGSizeMake(320.0f, 600.0f);
    self.sv.scrollEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - Broadcasting methods

- (IBAction) startBroadcast {
    
    if (!isBroadcasting) {
        [Flurry logEvent:@"Broadcasting NOW"];
        
        isBroadcasting = YES;
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.udid.text];
        
        // Initialize the Beacon Region
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                    major:[self.major.text integerValue]
                                                                    minor:[self.minor.text integerValue]
                                                               identifier:@"net.pushplay.test"];
        
        self.beaconData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    } else {
        
        isBroadcasting = NO;
        [Flurry logEvent:@"Broadcasting Stopped"];
        
        self.peripheralManager = nil;
        self.beaconData = nil;
        
        [self.broadcastButton setTitle:@"BROADCAST" forState:UIControlStateNormal];
        
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // Bluetooth is on
        
        // Update our status label
        [self.broadcastButton setTitle:@"Broadcasting..." forState:UIControlStateNormal];
        self.broadcastButton.titleLabel.text = @"Broadcasting...";
        
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.beaconData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        // Update our status label
        [self.broadcastButton setTitle:@"Stopped" forState:UIControlStateNormal];
        
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    } else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        [self.broadcastButton setTitle:@"Unsupported" forState:UIControlStateNormal];
        self.broadcastButton.enabled = FALSE;
    }
}

- (IBAction) generateRandomUUID {
    
    NSString *uuidString = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
    }

    self.udid.text = uuidString;
}

#pragma mark - Text Field Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
    if (textField.tag > 2) {
        doneButton.hidden = NO;
    } else {
        doneButton.hidden = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    doneButton.hidden = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_identifier.text forKey:@"identifier"];
    [defaults setObject:_udid.text forKey:@"uuid"];
    [defaults setObject:_major.text forKey:@"major"];
    [defaults setObject:_minor.text forKey:@"minor"];
    [defaults synchronize];
    
    activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField.tag == 1) {
        return YES;
    } else if (textField.tag == 2) {
        return (newLength > 40) ? NO : YES;
    } else {
        return ([[NSString stringWithFormat:@"%@%@", textField.text, string] integerValue] > 32767) ? NO : YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1)
        [self.udid becomeFirstResponder];
    else
        [self.major becomeFirstResponder];
    return YES;
}

#pragma mark - Keyboard Methods

- (void) doneButton:(id)sender {
    if ([self.major isFirstResponder]) {
        [self.minor becomeFirstResponder];
    } else {
        [self.minor resignFirstResponder];
    }
}

- (void) setDoneButton:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
        [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
        [keyboardView addSubview:doneButton];
        [keyboardView bringSubviewToFront:doneButton];
        
        [UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02
                              delay:.0
                            options:[[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                         animations:^{
                             self.view.frame = CGRectOffset(self.view.frame, 0, 0);
                         } completion:nil];
    });
}

- (void) keyboardDidShow:(NSNotification *)notification {
    [self setDoneButton:notification];
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.sv.contentInset = contentInsets;
    self.sv.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.sv scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.sv.contentInset = contentInsets;
    self.sv.scrollIndicatorInsets = contentInsets;
    self.sv.contentOffset = CGPointZero;
}

@end