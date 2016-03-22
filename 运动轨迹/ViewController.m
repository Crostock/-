//
//  ViewController.m
//  运动轨迹
//
//  Created by FengHua on 3/21/16.
//  Copyright © 2016 FengHua. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>  //高德
#import <MapKit/MapKit.h>     //自带

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MAMapServices sharedServices]setApiKey:@"0ad3f46403833893450e6dd8de51e457"];
    

    
    MKMapView *map2 = [[MKMapView alloc]initWithFrame:self.view.bounds];
    
    
    [self.view addSubview:map2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
