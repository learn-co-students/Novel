//
//  PGBSettingsViewController.m
//  ProjectBook
//
//  Created by Lauren Reed on 12/7/15.
//  Copyright © 2015 FIS. All rights reserved.
//

#import "PGBSettingsViewController.h"
#import "PGBRealmBook.h"

@interface PGBSettingsViewController ()

@end

@implementation PGBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)logoutButtonTapped:(id)sender {
    //update parse when user logs out
//    [PGBRealmBook updateParseWithRealmBookDataWithCompletion:^{
//        NSLog(@"update parse completed");
//        
//        [PFUser logOut];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }];
}

@end
