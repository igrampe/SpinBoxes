//
//  SpinView.m
//  SpinBoxes
//
//  Created by Sema Belokovsky on 01.07.15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

#import "SpinView.h"
#import <UIKit/UIGeometry.h>

BOOL isEqual(CGFloat A, CGFloat B) {
    return (fabs(A-B) < 0.01);
}

BOOL isCloser(CGFloat value, CGFloat value1, CGFloat value2) {
    // is value closer to value1 than value2
    BOOL result = 0;
    if (fabs(value-value1) < fabs(value-value2)) {
        result = YES;
    }
    return result;
}

@implementation SpinView  {
    NSMutableArray *_containerViews;
    CGFloat _containerWidth;
    CGFloat _containerHeight;
    CGPoint _lastPanLocation;
    CGPoint _lastTranslation;
    BOOL _canReturn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:pan];
    
    _containerViews = [NSMutableArray new];
    for (NSInteger i = 0; i < 8; ++i) {
        [_containerViews addObject:[ContainerView new]];
    }
    
    for (NSInteger i = 0; i < [_containerViews count]; ++i) {
        ContainerView *cv = [_containerViews objectAtIndex:i];
        cv.tag = i;
        cv.label.text = [NSString stringWithFormat:@"%ld", (long)i+1];
        [self addSubview:cv];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
        [cv addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [cv addGestureRecognizer:longPress];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _containerWidth = (self.bounds.size.width-8*4)/3;
    _containerHeight = _containerWidth*4/3;
    for (ContainerView *cv in _containerViews) {
        cv.frame = CGRectMake(0, 0, _containerWidth, _containerHeight);
        CGPoint offset = [self offsetForTag:cv.tag];
        cv.center = CGPointMake(self.center.x+offset.x, self.center.y+offset.y);
    }
    
}

- (CGPoint)offsetForTag:(NSInteger)tag {
    CGPoint offset = CGPointZero;
    
    // left
    if ((3 <= tag) && (tag <= 5)) {
        offset.x -= _containerWidth+8;
    }
    
    // right
    if (((0 <= tag) && (tag <= 1)) || tag == 7) {
        offset.x += _containerWidth+8;
    }
    
    // top
    if ((5 <= tag) && (tag <= 7)) {
        offset.y -= _containerHeight+8;
    }
    
    // bottom
    if ((1 <= tag) && (tag <= 3)) {
        offset.y += _containerHeight+8;
    }
    
    return offset;
}

#pragma makr - Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _canReturn = YES;
            _lastPanLocation = [panGestureRecognizer locationInView:self];
            for (ContainerView *cv in _containerViews) {
                [self stopAnimationForContainer:cv];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGestureRecognizer translationInView:self];
            CGPoint location = [panGestureRecognizer locationInView:self];
            
            BOOL horizontal = NO;
            BOOL clockwise = NO;
            
            if (location.y >= self.center.y+(_containerHeight/2+8) || location.y <= self.center.y-(_containerHeight/2+8)) {
                if (location.x <= self.center.x-(_containerWidth/2+8) || location.x >= self.center.x+(_containerWidth/2+8)) {
                    horizontal = fabs(_lastPanLocation.x-location.x) > fabs(_lastPanLocation.y-location.y);
                } else {
                    horizontal = YES;
                }
            }
            
            if (horizontal) {
                if (((location.x-_lastPanLocation.x > 0) && _lastPanLocation.y < self.center.y) ||
                    ((location.x-_lastPanLocation.x < 0) && _lastPanLocation.y > self.center.y)) {
                    clockwise = YES;
                } else {
                    clockwise = NO;
                }
            } else {
                if (((location.y-_lastPanLocation.y > 0) && _lastPanLocation.x > self.center.x) ||
                    ((location.y-_lastPanLocation.y < 0) && _lastPanLocation.x < self.center.x)) {
                    clockwise = YES;
                } else {
                    clockwise = NO;
                }
            }
            
            [self makeStepWithTranslation:translation location:location horizontal:horizontal clockwise:clockwise];
            
            _lastPanLocation = [panGestureRecognizer locationInView:self];
            _lastTranslation = translation;
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [panGestureRecognizer velocityInView:self];
            CGPoint translation = [panGestureRecognizer translationInView:self];
            CGPoint location = [panGestureRecognizer locationInView:self];
            
            BOOL horizontal = NO;
            BOOL clockwise = NO;
            
            if (location.y >= self.center.y+(_containerHeight/2+8) || location.y <= self.center.y-(_containerHeight/2+8)) {
                if (location.x >= self.center.x-(_containerWidth/2+8) && location.x <= self.center.x+(_containerWidth/2+8)) {
                    horizontal = YES;
                } else {
                    horizontal = fabs(translation.x+velocity.x) > fabs(translation.y+velocity.y);
                }
            }
            
            if (_canReturn) {
                if (horizontal) {
                    if (fabs(translation.x+_lastTranslation.x) > (_containerWidth/2)) {
                        _canReturn = NO;
                    }
                } else {
                    if (fabs(translation.y+_lastTranslation.y) > (_containerHeight/2)) {
                        _canReturn = NO;
                    }
                }
            }
            
            CGFloat usedVelocity;
            CGFloat usedTranslation;

            CGFloat ratio = (_containerHeight+8)/(_containerWidth+8);
            
            if (horizontal) {
                usedVelocity = velocity.x*ratio;
                usedTranslation = translation.x*ratio;
                if (((velocity.x > 0) && _lastPanLocation.y < self.center.y) ||
                    ((velocity.x < 0) && _lastPanLocation.y > self.center.y)) {
                    clockwise = YES;
                } else {
                    clockwise = NO;
                }
            } else {
                usedVelocity = velocity.y;
                usedTranslation = translation.y;
                if (((velocity.y > 0) && _lastPanLocation.x > self.center.x) ||
                    ((velocity.y < 0) && _lastPanLocation.x < self.center.x)) {
                    clockwise = YES;
                } else {
                    clockwise = NO;
                }
            }
            
            for (ContainerView *cv in _containerViews) {
                [self animateContainer:cv withVelocity:usedVelocity translation:usedTranslation clockwise:clockwise];
            }
        }
            break;
        default:
            break;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    NSString *message = [NSString stringWithFormat:@"Tap #%ld", (long)tap.view.tag+1];
    [self.delegate showMessage:message];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    NSString *message = nil;
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            message = [NSString stringWithFormat:@"Longpress start #%ld", (long)longPress.view.tag+1];
            [self.delegate showMessage:message];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            message = [NSString stringWithFormat:@"End Longpress #%ld", (long)longPress.view.tag+1];
            [self.delegate showMessage:message];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Move

- (void)makeStepWithTranslation:(CGPoint)translation
                       location:(CGPoint)location
                     horizontal:(BOOL)horizontal
                      clockwise:(BOOL)clockwise {
    for (ContainerView *cv in _containerViews) {
        CGPoint center;
        CGFloat pointsReamaining = 0;
        
        CGFloat ratio = (_containerHeight+8)/(_containerWidth+8);
        
        if (horizontal) {
            pointsReamaining = (location.x-_lastPanLocation.x)*ratio;
        } else {
            pointsReamaining = location.y-_lastPanLocation.y;
        }
        
        pointsReamaining = MIN(fabs(pointsReamaining), (_containerHeight+8));
        if (pointsReamaining > (_containerHeight)/2) {
            _canReturn = NO;
        }
        CGFloat length = 0;
        while (pointsReamaining > 0) {
            center = cv.center;
            if ([self canMoveDown:center clockwise:clockwise]) {
                length = [self moveDownPoint:&center maxLength:pointsReamaining];
            } else if ([self canMoveUp:center clockwise:clockwise]) {
                length = [self moveUpPoint:&center maxLength:pointsReamaining];
            } else if ([self canMoveLeft:center clockwise:clockwise]) {
                length = [self moveLeftPoint:&center maxLength:pointsReamaining];
            } else if ([self canMoveRight:center clockwise:clockwise]) {
                length = [self moveRightPoint:&center maxLength:pointsReamaining];
            }
            cv.center = center;
            pointsReamaining -= length;
        }
    }
}

- (CGFloat)moveDownPoint:(CGPoint *)center maxLength:(CGFloat)maxLength {
    CGFloat length = 0;
    if (fabs(self.center.y+(_containerHeight+8)-center->y) >= maxLength) {
        length = MIN(maxLength, (_containerHeight+8));
    } else {
        length = fabs(self.center.y+(_containerHeight+8)-center->y);
    }
    *center = CGPointMake(center->x, center->y+length);
    return length;
}

- (CGFloat)moveUpPoint:(CGPoint *)center maxLength:(CGFloat)maxLength {
    CGFloat length = 0;
    if (fabs(self.center.y-(_containerHeight+8)-center->y) >= maxLength) {
        length = MIN(maxLength, (_containerHeight+8));
    } else {
        length = fabs(self.center.y-(_containerHeight+8)-center->y);
    }
    *center = CGPointMake(center->x, center->y-length);
    return length;
}

- (CGFloat)moveLeftPoint:(CGPoint *)center maxLength:(CGFloat)maxLength {
    CGFloat ratio = (_containerWidth*2+16)/(_containerHeight*2+16);
    CGFloat length = 0;
    if (fabs(self.center.x-(_containerWidth+8)-center->x) >= maxLength*ratio) {
        length = MIN(_containerWidth+8, maxLength*ratio);
    } else {
        length = fabs(self.center.x-(_containerWidth+8)-center->x);
    }
    *center = CGPointMake(center->x-length, center->y);
    return length/ratio;
}

- (CGFloat)moveRightPoint:(CGPoint *)center maxLength:(CGFloat)maxLength {
    CGFloat ratio = (_containerWidth*2+16)/(_containerHeight*2+16);
    CGFloat length = 0;
    if (fabs(self.center.x+(_containerWidth+8)-center->x) >= maxLength*ratio) {
        length = MIN(_containerWidth+8, maxLength*ratio);
    } else {
        length = fabs(self.center.x+(_containerWidth+8)-center->x);
    }
    *center = CGPointMake(center->x+length, center->y);
    return length/ratio;
}
#pragma mark - Stop point

- (CGPoint)stopPointForCenter:(CGPoint)center clockwise:(BOOL)clockwise canReturn:(BOOL)canReturn {
    CGPoint stop = center;
    if (isEqual(center.x, self.center.x+_containerWidth+8)) {
        if (center.y < self.center.y && center.y > self.center.y-(_containerHeight+8)) {
            if (canReturn) {
                if (isCloser(center.y, self.center.y, self.center.y-(_containerHeight+8))) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y-(_containerHeight+8));
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y-(_containerHeight+8));
                }
            }
        } else if (center.y < self.center.y+(_containerHeight+8) && center.y > self.center.y) {
            if (canReturn) {
                if (isCloser(center.y, self.center.y, self.center.y+(_containerHeight+8))) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y+(_containerHeight+8));
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(center.x, self.center.y+(_containerHeight+8));
                } else {
                    stop = CGPointMake(center.x, self.center.y);
                }
            }
        }
    } else if (isEqual(center.x, self.center.x-(_containerWidth+8))) {
        if (center.y < self.center.y+(_containerHeight+8) && center.y > self.center.y) {
            if (canReturn) {
                if (isCloser(center.y, self.center.y, self.center.y+(_containerHeight+8))) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y+(_containerHeight+8));
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y+(_containerHeight+8));
                }
            }
        } else if (center.y < self.center.y && center.y > self.center.y-(_containerHeight+8)) {
            if (canReturn) {
                if (isCloser(center.y, self.center.y, self.center.y-(_containerHeight+8))) {
                    stop = CGPointMake(center.x, self.center.y);
                } else {
                    stop = CGPointMake(center.x, self.center.y-(_containerHeight+8));
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(center.x, self.center.y-(_containerHeight+8));
                } else {
                    stop = CGPointMake(center.x, self.center.y);
                }
            }
        }
    } else if (isEqual(center.y, self.center.y+(_containerHeight+8))) {
        if (center.x < self.center.x+(_containerWidth+8) && center.x > self.center.x) {
            if (canReturn) {
                if (isCloser(center.x, self.center.x, self.center.x+(_containerWidth+8))) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x+(_containerWidth+8), center.y);
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x+(_containerWidth+8), center.y);
                }
            }
        } else if (center.x < self.center.x && center.x > self.center.x-(_containerWidth+8)) {
            if (canReturn) {
                if (isCloser(center.x, self.center.x, self.center.x-(_containerWidth+8))) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x-(_containerWidth+8), center.y);
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(self.center.x-(_containerWidth+8), center.y);
                } else {
                    stop = CGPointMake(self.center.x, center.y);
                }
            }
        }
    } else if (isEqual(center.y, self.center.y-(_containerHeight+8))) {
        if (center.x < self.center.x && center.x > self.center.x-(_containerWidth+8)) {
            if (canReturn) {
                if (isCloser(center.x, self.center.x, self.center.x-(_containerWidth+8))) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x-(_containerWidth+8), center.y);
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x-(_containerWidth+8), center.y);
                }
            }
        } else if (center.x < self.center.x+(_containerWidth+8) && center.x > self.center.x) {
            if (canReturn) {
                if (isCloser(center.x, self.center.x, self.center.x+(_containerWidth+8))) {
                    stop = CGPointMake(self.center.x, center.y);
                } else {
                    stop = CGPointMake(self.center.x+(_containerWidth+8), center.y);
                }
            } else {
                if (clockwise) {
                    stop = CGPointMake(self.center.x+(_containerWidth+8), center.y);
                } else {
                    stop = CGPointMake(self.center.x, center.y);
                }                
            }
        }
    }
    return stop;
}

#pragma mark - check move

- (BOOL)canMoveUp:(CGPoint)center clockwise:(BOOL)clockwise {
    BOOL result = NO;
    if (center.y > self.center.y-(_containerHeight+8)) {
        if (clockwise) {
            if (isEqual(center.x, self.center.x-(_containerWidth+8))) {
                result = YES;
            }
        } else if (isEqual(center.x, self.center.x+(_containerWidth+8))) {
            result = YES;
        }
    }
    return result;
}

- (BOOL)canMoveDown:(CGPoint)center clockwise:(BOOL)clockwise {
    BOOL result = NO;
    if (center.y < self.center.y+(_containerHeight+8)) {
        if (clockwise) {
            if (isEqual(center.x, self.center.x+(_containerWidth+8))) {
                result = YES;
            }
        } else {
            if (isEqual(center.x, self.center.x-(_containerWidth+8))) {
                result = YES;
            }
        }
    }
    
    return result;
}

- (BOOL)canMoveLeft:(CGPoint)center clockwise:(BOOL)clockwise {
    BOOL result = NO;
    
    if (center.x > self.center.x-(_containerWidth+8)) {
        if (clockwise) {
            if (isEqual(center.y, self.center.y+(_containerHeight+8))) {
                result = YES;
            }
        } else {
            if (isEqual(center.y, self.center.y-(_containerHeight+8))) {
                result = YES;
            }
        }
    }
    
    return result;
}

- (BOOL)canMoveRight:(CGPoint)center clockwise:(BOOL)clockwise {
    BOOL result = NO;
    
    if (center.x < self.center.x+(_containerWidth+8)) {
        if (clockwise) {
            if (isEqual(center.y, self.center.y-(_containerHeight+8))) {
                result = YES;
            }
        } else {
            if (isEqual(center.y, self.center.y+(_containerHeight+8))) {
                result = YES;
            }
        }
    }
    
    return result;
}

#pragma mark - Animtaion

- (void)stopAnimationForContainer:(ContainerView *)cv {
    CGPoint position = [(CALayer *)[cv.layer presentationLayer] position];
    [cv.layer removeAnimationForKey:@"pathAnimation"];
    if (!isnan(position.x) && !isnan(position.y)) {
        cv.layer.position = position;
    }
}

- (void)animateContainer:(ContainerView *)cv
            withVelocity:(CGFloat)velocity
             translation:(CGFloat)translation
               clockwise:(BOOL)clockwise {
    double animationTime = (translation>(_containerHeight+8))?1:0.5;
    CGPoint center = cv.center;
    
    CGFloat pathLengthReamaining = MIN(fabs(translation), (_containerHeight+8)*8);
    CGFloat length = 0;
    CGFloat totalPathLength = pathLengthReamaining;
    
    NSMutableArray *animtaionsArr = [NSMutableArray new];
    NSMutableArray *stepsFactors = [NSMutableArray new];
    
    while (pathLengthReamaining > 0) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        CGPoint point = center;
        
        if ([self canMoveDown:center clockwise:clockwise]) {
            length = [self moveDownPoint:&center maxLength:pathLengthReamaining];
        } else if ([self canMoveUp:center clockwise:clockwise]) {
            length = [self moveUpPoint:&center maxLength:pathLengthReamaining];
        } else if ([self canMoveLeft:center clockwise:clockwise]) {
            length = [self moveLeftPoint:&center maxLength:pathLengthReamaining];
        } else if ([self canMoveRight:center clockwise:clockwise]) {
            length = [self moveRightPoint:&center maxLength:pathLengthReamaining];
        }
        pathLengthReamaining -= length;
        
        animation.calculationMode = kCAAnimationPaced;
        animation.values = @[[NSValue valueWithCGPoint:point],
                             [NSValue valueWithCGPoint:CGPointMake(center.x, center.y)]];
        [stepsFactors addObject:[NSNumber numberWithDouble:length]];
        [animtaionsArr addObject:animation];
        animation.delegate = self;
    }
    
    CGPoint stop = [self stopPointForCenter:center clockwise:clockwise canReturn:_canReturn];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.calculationMode = kCAAnimationPaced;
    CGFloat stopStepRatio = 1;
    if (fabs(center.x-stop.x) > fabs(center.y-stop.y)) {
        [stepsFactors addObject:[NSNumber numberWithDouble:fabs(center.x-stop.x)]];
        stopStepRatio = (_containerWidth*2+16)/(_containerHeight*2+16);
    } else {
        [stepsFactors addObject:[NSNumber numberWithDouble:fabs(center.y-stop.y)]];
    }
    animation.values = @[[NSValue valueWithCGPoint:center],
                         [NSValue valueWithCGPoint:CGPointMake(stop.x, stop.y)]];
    animation.delegate = self;
    [animtaionsArr addObject:animation];
    
    double time = 0;
    for (NSInteger i = 0; i < [animtaionsArr count]-1; ++i) {
        CAKeyframeAnimation *a = [animtaionsArr objectAtIndex:i];
        double stepFactor = [[stepsFactors objectAtIndex:i] doubleValue];
        a.duration = animationTime*(stepFactor/totalPathLength);
        a.beginTime = time;
        time += a.duration;
    }
    
    CAKeyframeAnimation *a = [animtaionsArr lastObject];
    double stepFactor = [[stepsFactors lastObject] doubleValue];
    a.duration = animationTime*(stepFactor/totalPathLength)/stopStepRatio;
    a.beginTime = time;
    a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    time += a.duration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [group setDuration:time];
    [group setAnimations:animtaionsArr];
    
    [cv.layer addAnimation:group forKey:@"pathAnimation"];
    cv.layer.position = CGPointMake(stop.x, stop.y);
}

@end
