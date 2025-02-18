//
//  TileOverlayViewController.m
//  OfficialDemo3D
//
//  Created by Li Fei on 3/3/14.
//  Copyright (c) 2014 songjian. All rights reserved.
//

#import "TileOverlayViewController.h"

#define TileOverlayViewControllerTemplate   @"http://106.3.73.18:8080/tileserver/Tile?x={x}&y={y}&z={z}&f=%d"
#define TileOverlayViewControllerMinimumZ   18
#define TileOverlayViewControllerMaximumZ   20
#define TileOverlayViewControllerCoordinate CLLocationCoordinate2DMake(39.910695, 116.372830)
#define TileOverlayViewControllerDistance   200

@interface TileOverlayViewController ()

@property (nonatomic, strong) MATileOverlay *tileOverlay;

@property (nonatomic, assign) NSInteger floor;

@end

@implementation TileOverlayViewController

@synthesize tileOverlay = _tileOverlay;
@synthesize floor       = _floor;

#pragma mark - Utility

/* 根据floor构建室内地图对应的MATileOverlay. */
- (MATileOverlay *)constructTileOverlayWithFloor:(NSInteger)floor
{
    /* 构建tileOverlay的URL模版. */
    NSString *URLTemplate = [NSString stringWithFormat:TileOverlayViewControllerTemplate, floor];
    
    MATileOverlay *tileOverlay = [[MATileOverlay alloc] initWithURLTemplate:URLTemplate];
    
    /* minimumZ 是tileOverlay的可见最小Zoom值. */
    tileOverlay.minimumZ = TileOverlayViewControllerMinimumZ;
    /* minimumZ 是tileOverlay的可见最大Zoom值. */
    tileOverlay.maximumZ = TileOverlayViewControllerMaximumZ;
    
    /* boundingMapRect 是用来 设定tileOverlay的可渲染区域. */
    tileOverlay.boundingMapRect = MAMapRectForCoordinateRegion(MACoordinateRegionMakeWithDistance(TileOverlayViewControllerCoordinate, TileOverlayViewControllerDistance, TileOverlayViewControllerDistance));
    
    return tileOverlay;
}

/* 切换楼层. */
- (void)transitToFloor:(NSInteger)floor
{
    /* 删除之前的楼层. */
    [self.mapView removeOverlay:self.tileOverlay];
    
    /* 添加新的楼层. */
    self.tileOverlay = [self constructTileOverlayWithFloor:floor];
    [self.mapView addOverlay:self.tileOverlay];
}

#pragma mark - MKMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayView *tileOverlayView = [[MATileOverlayView alloc] initWithTileOverlay:overlay];
        
        return tileOverlayView;
    }
    
    return nil;
}

#pragma mark - Handle Action

- (void)changeFloorAction:(UISegmentedControl *)segmentedControl
{
    self.floor = segmentedControl.selectedSegmentIndex + 1;
    
    [self transitToFloor:self.floor];
}

#pragma mark - initialization

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UISegmentedControl *floorSegmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                 [NSArray arrayWithObjects:
                                                  @"1 层",
                                                  @"2 层",
                                                  @"3 层",
                                                  nil]];
    floorSegmentedControl.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 100, 40);
    floorSegmentedControl.selectedSegmentIndex  = self.floor - 1;
    floorSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [floorSegmentedControl addTarget:self action:@selector(changeFloorAction:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *floorItem = [[UIBarButtonItem alloc] initWithCustomView:floorSegmentedControl];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, floorItem, flexbleItem, nil];
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.floor = 1;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initToolBar];
    
    self.mapView.centerCoordinate   = TileOverlayViewControllerCoordinate;
    self.mapView.zoomLevel          = 19;
    
    [self transitToFloor:self.floor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

@end
