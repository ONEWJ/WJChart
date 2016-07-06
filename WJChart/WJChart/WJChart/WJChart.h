//
//  WJChart.h
//  WJChart
//
//  Created by 王文娟 on 16/7/6.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJChart;
typedef NS_ENUM(NSInteger, ChartType)
{
    ChartTypeNone = 0,
    ChartTypeHorizon,
    ChartTypeHeap,
    ChartTypeLine,
    ChartTypePie
};
@protocol WJChartDataSourse <NSObject>
@optional
-(NSString *)WJChart:(WJChart *)WJChart titleForValueAtIndex:(NSInteger)index;
-(NSArray *)XTitleInWJChart:(WJChart *)WJChart;

@end


@protocol WJChartDelegate <NSObject>
@optional
-(void)WJChart:(WJChart *)WJChart didSelectAtIndex:(int)index;
-(void)WJChart:(WJChart *)WJChart didEndDrawChartWithColors:(NSArray *)colors;
@end
@interface WJChart : UIView

@property (nonatomic,strong) NSArray *Values;
@property (nonatomic, weak)IBOutlet id<WJChartDataSourse> dataSource;
@property (nonatomic, weak)IBOutlet id<WJChartDelegate> delegate;
@property (nonatomic, assign, readonly) ChartType currentChartType;
@property (nonatomic, weak, readonly) UIColor *currentSelectedColor;
@property(nonatomic,assign)BOOL hideBottomDesc;

-(void)drawChartWithType:(ChartType )chartType;
@end
