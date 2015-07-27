//
//  ContainerView.m
//  SpinBoxes
//
//  Created by Sema Belokovsky on 30.06.15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

#import "ContainerView.h"

@implementation ContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.label = [UILabel new];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

@end
