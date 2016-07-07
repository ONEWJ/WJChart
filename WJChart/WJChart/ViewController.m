//
//  ViewController.m
//  WJChart
//
//  Created by 王文娟 on 16/7/6.
//  Copyright © 2016年 EJU. All rights reserved.
//


#import "ViewController.h"
#import "WJChart.h"
@interface ViewController ()<WJChartDataSourse,WJChartDelegate>
@property (weak, nonatomic) IBOutlet WJChart *Chart;
@property (nonatomic, weak) UIButton *selectedBtn;
@property (nonatomic, weak) UIButton *selectedChartTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneDimentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *lineBtn;
@property(nonatomic,strong)NSMutableArray *chartTitleArr;
@property(nonatomic,strong)NSArray *chartDimArr;
@property (nonatomic, strong) NSArray *values;

@property (nonatomic, assign) ChartType selectedType;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedBtn = self.oneDimentionBtn;
    self.selectedChartTypeBtn = self.lineBtn;
    
    
    [self drawOneDimensionChart:self.oneDimentionBtn];
    
    [self.Chart drawChartWithType:ChartTypeLine];
    
    self.selectedType = ChartTypeLine;
}


#pragma mark - 切换图表类型

- (IBAction)line:(UIButton *)sender {
    
     self.selectedType = ChartTypeLine;
    
    [self updateChartTypeBtn:sender];
}
- (IBAction)heap:(id)sender {
    
    self.selectedType = ChartTypeHeap;
    
    [self updateChartTypeBtn:sender];
    
}
- (IBAction)horizon:(id)sender {
    
    self.selectedType = ChartTypeHorizon;
    
    [self updateChartTypeBtn:sender];
    
    
}
- (IBAction)pie:(id)sender {
    
    self.selectedType = ChartTypePie;
    
    [self updateChartTypeBtn:sender];
    
}


-(void)updateChartTypeBtn:(UIButton *)sender{

    if (self.selectedChartTypeBtn == sender) {
        return;
    }
    
    self.selectedChartTypeBtn.selected = NO;
    
    sender.selected = YES;
    
    self.selectedChartTypeBtn = sender;
    
    [self.Chart drawChartWithType:self.selectedType];

}





#pragma mark - 切换维度


- (IBAction)drawOneDimensionChart:(UIButton *)sender {
    
    
    self.chartDimArr = @[@[@"English",@"Chinese",@"Math",@"Physics"]];
    
    [self getPieTitlesWithArr:self.chartDimArr];
    
    self.values = @[
                    @25,
                    @20,
                    @45,
                    @10
                    ];
    
    [self updateDimensionBtnState:sender];
    
    
}
- (IBAction)drawTwoDimensionChart:(UIButton *)sender {
    
    
    
    self.chartDimArr = @[@[@"English",@"Chinese",@"Math",@"Physics"],@[@"男",@"女"]];
    
    [self getPieTitlesWithArr:self.chartDimArr];
    
    self.values = @[
                    @20,
                    @10,
                    @5,
                    @10,
                    @30,
                    @2,
                    @5,
                    @18
                    ];
    
    [self updateDimensionBtnState:sender];
    
    
    
}
- (IBAction)drawThreeDimensionChart:(UIButton *)sender {
    
    
    
    self.chartDimArr = @[@[@"Chinese",@"Math"],@[@"华东",@"华南",@"华北"],@[@"男",@"女"]];
    
    [self getPieTitlesWithArr:self.chartDimArr];
    
    self.values = @[
                    @20,
                    @10,
                    @2,
                    @5,
                    @5,
                    @2,
                    @5,
                    @13,
                    @5,
                    @10,
                    @5,
                    @18
                    ];
    
    [self updateDimensionBtnState:sender];
    
}


-(void)updateDimensionBtnState:(UIButton *)sender{

    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    
    self.selectedBtn.selected = NO;
    
    self.selectedBtn = sender;
    
    [self.Chart drawChartWithType:self.selectedType];
    
}



#pragma mark -  WJChartDelegate
-(void)chart:(WJChart *)chart didSelectAtIndex:(int)index{
    
    NSLog(@"点击了－－－%d，，当前的颜色:%@",index,self.Chart.currentSelectedColor);
    
}
-(NSString *)chart:(WJChart *)chart titleForValueAtIndex:(NSInteger)index{
    
    return self.chartTitleArr[index];
}
-(NSArray *)XTitleInWJChart:(WJChart *)chart{
    
    return self.chartDimArr;
}
-(NSArray *)ValuesInWJChart:(WJChart *)chart{
    
    return  self.values;
    
}

#warning todo - 后期有时间放到里面去

-(void)getPieTitlesWithArr:(NSArray *)titleArray{
    
    NSMutableArray *names=[NSMutableArray array];
    if(titleArray.count==1){
        [names addObjectsFromArray:titleArray[0]];
    }
    else if (titleArray.count==2){
        [names addObjectsFromArray:[self appendNameWithArr1:titleArray[0] withArr2:titleArray[1]]];
    }else if (titleArray.count==3){
        NSArray *tempArr=[self appendNameWithArr1:titleArray[0] withArr2:titleArray[1]];
        [names addObjectsFromArray:[self appendNameWithArr1:tempArr withArr2:titleArray[2]]];
    }
    self.chartTitleArr =names;
    
}
-(NSMutableArray *)appendNameWithArr1:(NSArray *)Arr1 withArr2:(NSArray *)Arr2{
    NSMutableArray *CKArr=[NSMutableArray array];
    for (int i = 0; i < Arr1.count; i++) {
        NSString *  str1 = Arr1[i];
        for (int j = 0; j < Arr2.count; j ++) {
            NSString * str2 = Arr2[j];
            [CKArr addObject:[NSString stringWithFormat:@"%@,%@",str1,str2]];
        }
    }
    return CKArr;
}


@end
