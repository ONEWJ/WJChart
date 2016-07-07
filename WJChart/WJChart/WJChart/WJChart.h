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
-(NSString *)chart:(WJChart *)chart titleForValueAtIndex:(NSInteger)index;


-(NSArray *)XTitleInWJChart:(WJChart *)chart;
/**
 *  每一块的比例值
 *
 *  @param chartView self
 *
 *  @return 比例值数组
 */
-(NSArray *)ValuesInWJChart:(WJChart *)chart;

@end


@protocol WJChartDelegate <NSObject>
@optional
-(void)chart:(WJChart *)chart didSelectAtIndex:(int)index;
-(void)chart:(WJChart *)chart didEndDrawChartWithColors:(NSArray *)colors;
@end
@interface WJChart : UIView

@property (nonatomic, weak)IBOutlet id<WJChartDataSourse> dataSource;
@property (nonatomic, weak)IBOutlet id<WJChartDelegate> delegate;
@property (nonatomic, assign, readonly) ChartType currentChartType;
@property (nonatomic, weak, readonly) UIColor *currentSelectedColor;
@property(nonatomic,assign)BOOL hideBottomDesc;

-(void)drawChartWithType:(ChartType )chartType;
@end
