//
//  PGBTabBarViewController.m
//  ProjectBook
//
//  Created by Wo Jun Feng on 12/2/15.
//  Copyright © 2015 FIS. All rights reserved.
//

#import "PGBTabBarViewController.h"
#import <IonIcons.h>

@interface PGBTabBarViewController ()

@end

@implementation PGBTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:136.0f/255.0f blue:62.0f/255.0 alpha:1.0] }
                                             forState:UIControlStateNormal];
    
    UIImage *homeIcon = [IonIcons imageWithIcon:ion_ios_home
                                  iconColor:[UIColor colorWithRed:0 green:136.0f/255.0f blue:62.0f/255.0 alpha:1.0]
                                   iconSize:30.0f
                                  imageSize:CGSizeMake(90.0f, 90.0f)];
    [self.tabBar.items[0] setTitle:@"Home"];
    [self.tabBar.items[0] setImage:homeIcon];

    
    UIImage *searchIcon = [IonIcons imageWithIcon:ion_ios_search_strong
                                        iconColor:[UIColor colorWithRed:0 green:136.0f/255.0f blue:62.0f/255.0 alpha:1.0]
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(90.0f, 90.0f)];
    [self.tabBar.items[1] setTitle:@"Search"];
    [self.tabBar.items[1] setImage:searchIcon];
    
    UIImage *libraryIcon = [IonIcons imageWithIcon:ion_ios_book
                                         iconColor:[UIColor colorWithRed:0 green:136.0f/255.0f blue:62.0f/255.0 alpha:1.0]
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(90.0f, 90.0f)];
    [self.tabBar.items[2] setTitle:@"Library"];
    [self.tabBar.items[2] setImage:libraryIcon];

}
@end
