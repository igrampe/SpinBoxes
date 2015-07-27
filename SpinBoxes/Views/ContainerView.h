//
//  ContainerView.h
//  SpinBoxes
//
//  Created by Sema Belokovsky on 30.06.15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ContainerViewStateDefault = 0,
    ContainerViewStateAnimating = 1
} ContainerViewState;

@interface ContainerView : UIView

@property UILabel *label;
@property ContainerViewState state;

@end
