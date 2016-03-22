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


//
//#import "MovingAnnotationSource/MovingAnnotationView.h"
//#import "MovingAnnotationSource/TracingPoint.h"
//#import "MovingAnnotationSource/Util.h"


#import "MovingAnnotationView.h"
#import "TracingPoint.h"
#import "Util.h"


@interface ViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView * map;
@property (nonatomic, strong) MAPointAnnotation * car;

@end

@implementation ViewController {
    NSMutableArray * _tracking;
    CFTimeInterval _duration;
    NSArray *TrackingPointsArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
          [[MAMapServices sharedServices]setApiKey:@"0ad3f46403833893450e6dd8de51e457"];
        NSData *jsdata     = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tracking" ofType:@"json"]];
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
        TrackingPointsArr  = dataArray ;

    
    [self.view addSubview:self.map];
    [self initBtn];
    [self initAnnotation];
}



- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    
    
    @autoreleasepool {
        MAPolyline *route = [MAPolyline polylineWithCoordinates:coords count:count];
        [self.map addOverlay:route];
        
        NSMutableArray * routeAnno = [NSMutableArray array];
        for (int i = 0 ; i < count; i++)
        {
            MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
            a.coordinate = coords[i];
            a.title = @"route";
            [routeAnno addObject:a];
        }
        [self.map addAnnotations:routeAnno];
        [self.map showAnnotations:routeAnno animated:NO];

    }
    
    //show route
    
}

- (void)initTrackingWithCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    @autoreleasepool {
        _tracking = [NSMutableArray array];
        for (int i = 0; i<count - 1; i++)
        {
            TracingPoint * tp = [[TracingPoint alloc] init];
            tp.coordinate = coords[i];
            tp.course = [Util calculateCourseFromCoordinate:coords[i] to:coords[i+1]];
            [_tracking addObject:tp];
        }
        
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = coords[count - 1];
        tp.course = ((TracingPoint *)[_tracking lastObject]).course;
        [_tracking addObject:tp];

    }
    }


#pragma mark - Action



//核心代码处，动画的开始
- (void)mov
{
    /* Step 3. */
    
    /* Find annotation view for car annotation. */
    MovingAnnotationView * carView = (MovingAnnotationView *)[self.map viewForAnnotation:self.car];
    
    /*
     Add multi points animation to annotation view.
     The coordinate of car annotation will be updated to the last coords after animation is over.
     */
    [carView addTrackingAnimationForPoints:_tracking duration:_duration];
}

- (void)initBtn
{
    @autoreleasepool {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0, self.view.frame.size.height * 0.2, 60, 20);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"move" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(mov) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];

    }
}

#pragma mark - Map Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    /* Step 2. */
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MovingAnnotationView *annotationView = (MovingAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MovingAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:pointReuseIndetifier];
        }
        
        if ([annotation.title isEqualToString:@"Car"])
        {
            UIImage *imge  =  [UIImage imageNamed:@"userPosition"];
            UIImage *t = [UIImage imageNamed:@"userPosition"];
            annotationView.image =  t;
            CGPoint centerPoint=CGPointZero;
            [annotationView setCenterOffset:centerPoint];
        }
        else if ([annotation.title isEqualToString:@"route"])
        {
            annotationView.image = [UIImage imageNamed:@"trackingPoints.png"];
        }
        
        return annotationView;
    }
    
    return nil;
}

- (MAPolylineView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    @autoreleasepool {
        if ([overlay isKindOfClass:[MAPolyline class]])
        {
            MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
            
            polylineView.lineWidth   = 3.f;
            polylineView.strokeColor = [UIColor colorWithRed:0 green:0.47 blue:1.0 alpha:0.9];
            
            return polylineView;
        }
        
        return nil;
    }
    
}

#pragma mark - Initialization

- (void)initAnnotation
{
    [self initRoute];
    
    /* Step 1. */
    //show car
    
    @autoreleasepool {
        self.car = [[MAPointAnnotation alloc] init];
        TracingPoint * start = [_tracking firstObject];
        self.car.coordinate = start.coordinate;
        self.car.title = @"Car";
        [self.map addAnnotation:self.car];

    }
    
    
    
}

- (MAMapView *)map
{
    if (!_map)
    {
        _map = [[MAMapView alloc] initWithFrame:self.view.frame];
        [_map setDelegate:self];
        //加入annotation旋转动画后，暂未考虑地图旋转的情况。
        _map.rotateCameraEnabled = NO;
        _map.rotateEnabled = NO;
    }
    return _map;
}


- (void)initRoute
{
    _duration = 8.0;
    
    NSUInteger count = [TrackingPointsArr count];
    CLLocationCoordinate2D * coords = malloc(count * sizeof(CLLocationCoordinate2D));
    
    
    
    for (int i =0; i<count; i++) {
        @autoreleasepool {
            NSDictionary *temp = TrackingPointsArr[i];
            coords[i] = CLLocationCoordinate2DMake([temp[@"lat"] doubleValue] , [temp[@"lng"] doubleValue]);
        }

    }
    

    
    [self showRouteForCoords:coords count:count];
    [self initTrackingWithCoords:coords count:count];
    
    if (coords) {
        free(coords);
    }
    
}

@end
