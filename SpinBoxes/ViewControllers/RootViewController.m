//
//  RootViewController.m
//  SpinBoxes
//
//  Created by Sema Belokovsky on 30.06.15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

#import "RootViewController.h"
#import "SpinView.h"
#import "ContainerView.h"

@implementation RootViewController {
    SpinView *_spinView;
    ContainerView *_container;
    UILabel *_logLabel;
    NSTimer *_messageTimer;
}

- (void)loadView {
    [super loadView];
    _spinView = [[SpinView alloc] initWithFrame:self.view.bounds];
    _spinView.delegate = self;
    [self.view addSubview:_spinView];
    
    _container = [ContainerView new];
    _container.backgroundColor = [UIColor redColor];
    [_spinView addSubview:_container];
    
    _logLabel = [UILabel new];
    _logLabel.textColor = [UIColor whiteColor];
    _logLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_logLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _logLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    _spinView.frame = self.view.bounds;
    CGFloat containerWidth = (_spinView.bounds.size.width-8*4)/3;
    CGFloat containerHeight = 4*containerWidth/3;
    _container.frame = CGRectMake(_spinView.center.x-containerWidth/2.0, _spinView.center.y-containerHeight/2.0, containerWidth, containerHeight);
}

- (void)hideMessage {
    _logLabel.hidden = YES;
}

#pragma mark - SpinViewDelegate

- (void)showMessage:(NSString *)message {
    [_messageTimer invalidate];
    _messageTimer = nil;
    _logLabel.hidden = NO;
    _logLabel.text = message;
    _messageTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideMessage) userInfo:nil repeats:NO];
}

@end
