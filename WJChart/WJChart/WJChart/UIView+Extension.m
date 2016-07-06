//
//  UIView+Extension.m
//  UIViewExtension
//
//  Created by 王文娟 on 15/8/7.
//  Copyright (c) 2015年 Angie. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
-(void)setX:(float)X
{
    CGRect Frame=self.frame;
    Frame.origin.x=X;
    self.frame=Frame;
}
-(void)setY:(float)Y
{
    CGRect Frame=self.frame;
    Frame.origin.y=Y;
    self.frame=Frame;
}
-(void)setWidth:(float)Width
{
    CGRect Frame=self.frame;
    Frame.size.width=Width;
    self.frame=Frame;
}
-(void)setHeight:(float)Height
{
    CGRect Frame=self.frame;
    Frame.size.height=Height;
    self.frame=Frame;
}
-(void)setMaxX:(float)MaxX
{
    self.X = MaxX - self.Width;
}
-(void)setMaxY:(float)MaxY
{
    self.Y=MaxY-self.Height;
}
-(void)setSize:(CGSize)Size
{
    CGRect frame = self.frame;
    frame.size = Size;
    self.frame = frame;
}
-(void)setCenterX:(float)CenterX
{
    CGPoint center=self.center;
    center.x=CenterX;
    self.center=center;
}
-(void)setCenterY:(float)CenterY
{
    CGPoint center=self.center;
    center.y=CenterY;
    self.center=center;
}
-(float)X
{
    return self.frame.origin.x;
}
-(float)Y
{
    return self.frame.origin.y;
}
-(float)Width
{
    return self.frame.size.width;
}
-(float)Height
{
    return self.frame.size.height;
}
-(float)MaxX
{
    return CGRectGetMaxX(self.frame);
}
-(float)MaxY
{
    return CGRectGetMaxY(self.frame);
}
-(float)CenterX
{
    return self.center.x;
}
-(float)CenterY
{
    return self.center.y;
}

-(CGSize)Size
{
    return self.frame.size;
}

@end
