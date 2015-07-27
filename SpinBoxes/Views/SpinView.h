//
//  SpinView.h
//  SpinBoxes
//
//  Created by Sema Belokovsky on 01.07.15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerView.h"

@protocol SpinViewDelegate <NSObject>

- (void)showMessage:(NSString *)message;

@end

@interface SpinView : UIView

@property (weak) id<SpinViewDelegate> delegate;

@end
