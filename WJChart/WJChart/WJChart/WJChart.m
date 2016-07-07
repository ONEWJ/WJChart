//
//  WJChart.m
//  WJChart
//
//  Created by 王文娟 on 16/7/6.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "WJChart.h"
// 颜色
#define WJColor(R, G, B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]

// 随机色
#define WJRandomColor WJColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

//底部描述View的高
#define contentDescViewH 60.0
//水平图的最大高度
#define HorizonMaxHeight 80.0
//堆叠图最大宽度
#define HeapMaxWight 100.0
@interface describeView : UIView
@property(nonatomic,weak)UIView *colorView;
@property(nonatomic,weak)UILabel *desc;
@end

@implementation describeView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        UIView *colorView=[[UIView alloc]init];
        self.colorView=colorView;
        [self addSubview:colorView];
        
        UILabel *desc=[[UILabel alloc]init];
        self.desc=desc;
        [self addSubview:desc];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.colorView.frame=CGRectMake(0, 3, 20, self.frame.size.height-6);
    self.desc.frame=CGRectMake(25, 0, [self.desc.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width, self.frame.size.height);
    
}
@end

@interface WJChart()
/**
 当前绘图的类型
 */
@property(nonatomic,assign)ChartType chartType;
@property(nonatomic,weak)UIView *coverRectView;
@property(nonatomic,weak)UIImageView *coverPieImage;
/**
 每一块的颜色
 */
@property(nonatomic,strong)NSMutableArray *colors;
@property(nonatomic,assign)CGPoint pieCenter;
@property(nonatomic,assign)CGFloat pieRadius;

@property (nonatomic, weak)UIColor *selectedColor;
/**
 每一个柱形的frame
 */
@property(nonatomic,strong)NSMutableArray *chartFrame;

/**
 底部描述的大View
 */
@property(nonatomic,weak)UIScrollView *contentDescView;
/**
 *  对颜色没有特殊要求，可以不要
 *  表示 heap，line的线条的颜色个数
 */
@property(nonatomic,assign)NSUInteger colorCount;


@property (nonatomic,strong) NSArray *Values;


@end
@implementation WJChart

#pragma mark - lazy
-(UIScrollView *)contentDescView{
    if(_contentDescView==nil){
        UIScrollView *contentDescView=[[UIScrollView alloc]init];
        contentDescView.showsHorizontalScrollIndicator=NO;
        contentDescView.showsVerticalScrollIndicator=NO;
        self.contentDescView=contentDescView;
        [self addSubview:contentDescView];
    }
    return _contentDescView;
}
-(NSMutableArray *)colors{
    if(_colors==nil){
        NSMutableArray *colors=[[NSMutableArray alloc]init];
        self.colors=colors;
    }
    return _colors;
}
-(NSMutableArray *)chartFrame{
    if(_chartFrame==nil){
        NSMutableArray *chartFrame=[[NSMutableArray alloc]init];
        self.chartFrame=chartFrame;
    }
    return _chartFrame;
}
#pragma mark - set and get
-(void)setHideBottomDesc:(BOOL)hideBottomDesc{
    _hideBottomDesc = hideBottomDesc;
    
    self.contentDescView.hidden = hideBottomDesc;
    
}
-(ChartType)currentChartType{
    return self.chartType;
}
-(UIColor *)currentSelectedColor{
    return self.selectedColor;
}

#pragma mark - drawMethod
-(void)drawChartWithType:(ChartType )chartType{
    
    self.chartType=chartType;
    
    if ([self.dataSource respondsToSelector:@selector(ValuesInWJChart:)]) {
        
        self.Values = [self.dataSource ValuesInWJChart:self];
        
    }
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect {
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.contentDescView=nil;
    [self.chartFrame removeAllObjects];
    [self.colors removeAllObjects];
    
    switch (self.chartType) {
        case ChartTypePie:
            [self drawPieInRect:rect];
            break;
        case ChartTypeHorizon:
            [self drawHorizontalViewInRect:rect];
            break;
        case ChartTypeHeap:
            [self drawHeapInRect:rect];
            break;
        case ChartTypeLine:
            [self drawLineInRect:rect];
            break;
            
        default:
            break;
    }
    
}
/**
 折线图
 */
-(void)drawLineInRect:(CGRect)rect{
    if([self.dataSource respondsToSelector:@selector(XTitleInWJChart:)]){
        NSArray *Xtitle = [self.dataSource XTitleInWJChart:self];
        NSArray *lineArr=Xtitle[Xtitle.count-1];
        NSUInteger lineCount=lineArr.count;
        NSUInteger Xcount=1;
        NSUInteger topCount=1;
        
        for (int i=0; i<Xtitle.count-1; i++) {
            NSArray *arr=Xtitle[i];
            if(Xtitle.count==3&&i==0){
                topCount=arr.count;
            }
            Xcount*=arr.count;
        }
        if(Xtitle.count==1){
            lineCount=1;
            Xcount=((NSArray *)Xtitle[0]).count;
        }
        self.colorCount=lineCount;
//        NSLog(@"lineCount=%zd,Xcount=%zd,topCount=%zd",lineCount,Xcount,topCount);
        
        if(Xtitle.count==3){
            NSArray *top=Xtitle[0];
            for (int i=0; i<top.count; i++) {
                UILabel *toptitle=[[UILabel alloc]initWithFrame:CGRectMake(i*rect.size.width/top.count, 0, rect.size.width/top.count, 30)];
                toptitle.textAlignment=NSTextAlignmentCenter;
                [self addSubview:toptitle];
                toptitle.text=top[i];
                toptitle.backgroundColor=WJRandomColor;
            }
        }
        //添加下方的label
        CGFloat oneTotalW = rect.size.width/Xcount;
        CGFloat bottomH=100+contentDescViewH;
        
        CGFloat max=[self.Values[0] doubleValue];
        for (NSNumber *num in self.Values) {
            max=max<[num doubleValue]?[num doubleValue]:max;
        }
        //最大的高度
        CGFloat maxHeight = rect.size.height-bottomH;
        //比例值为1的时候的高度
        CGFloat oneTotalH = (rect.size.height-bottomH-35) /(max/100.0);
        NSArray *arr=Xtitle.count>1?Xtitle[Xtitle.count-2]:Xtitle[0];
        for (int i=0; i<Xcount; i++) {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(i*oneTotalW, maxHeight, oneTotalW, 30)];
            label.textAlignment=NSTextAlignmentCenter;
            label.font=[UIFont systemFontOfSize:13];
            label.backgroundColor=[UIColor clearColor];
            label.text=arr[i%arr.count];
            [self addSubview:label];
        }
        //画线
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if(Xtitle.count==1){
            CGFloat h=[self.Values[0] floatValue]/100.0*oneTotalH;
            CGFloat x=oneTotalW/2;
            
            for (int k=0; k<self.Values.count; k++) {//记录每一个点所在位置（矩形来记录）
                CGFloat x=k*oneTotalW+oneTotalW/2;
                CGFloat h=[self.Values[k] floatValue]/100.0*oneTotalH;
                CGPoint center=CGPointMake(x, maxHeight-h);
                CGFloat r=8;
                CGRect rect=CGRectMake(center.x-r, center.y-r, 2*r, 2*r);
                CGContextAddEllipseInRect(ctx, rect);
                [[UIColor blueColor]set];
                CGContextFillPath(ctx);
                
                [self.chartFrame addObject:[NSValue valueWithCGRect:rect]];
            }
            [self.colors addObject:[UIColor blueColor]];
            CGContextMoveToPoint(ctx, x, maxHeight-h);
            for (int i=1; i<Xcount; i++) {//从第二个点开始连接
                x=oneTotalW/2+i*oneTotalW;
                h=[self.Values[i] floatValue]/100.0*oneTotalH;
                CGContextAddLineToPoint(ctx, x, maxHeight-h);
                CGContextSetLineWidth(ctx, 3);
                CGContextSetLineJoin(ctx, kCGLineJoinRound);
                CGContextSetLineCap(ctx, kCGLineCapRound);
                [[UIColor blueColor] set];
            }
            CGContextStrokePath(ctx);
        }else{//维度大于1的情况
            for (int i=0; i<lineCount; i++) {
                [self.colors addObject:WJRandomColor];
            }
            for (int k=0; k<self.Values.count; k++) {//记录每一个点所在位置（矩形来记录）
                CGFloat x=k/lineCount*oneTotalW+oneTotalW/2;
                CGFloat h=[self.Values[k] floatValue]/100.0*oneTotalH;
                CGPoint center=CGPointMake(x, maxHeight-h);
                CGFloat r=8;
                CGRect rect=CGRectMake(center.x-r, center.y-r, 2*r, 2*r);
                CGContextAddEllipseInRect(ctx, rect);
                UIColor *col=self.colors[k%lineCount];
                [col set];
                CGContextFillPath(ctx);
                
                [self.chartFrame addObject:[NSValue valueWithCGRect:rect]];
                
                if(k%(lineCount*(Xcount/topCount))<lineCount){
                    
                    CGContextMoveToPoint(ctx, x, maxHeight-h);//起点
                    
                    for (NSUInteger p=k+lineCount; p<k+(Xcount/topCount*lineCount); ){
                        x=p/lineCount*oneTotalW+oneTotalW/2;
                        h=[self.Values[p] floatValue]/100.0*oneTotalH;
                        CGContextAddLineToPoint(ctx,x , maxHeight-h);
                        p+=lineCount;
                    }
                    CGContextSetLineWidth(ctx, 3);
                    CGContextSetLineJoin(ctx, kCGLineJoinRound);
                    CGContextSetLineCap(ctx, kCGLineCapRound);
                    UIColor *color=self.colors[k%lineCount];
                    [color set];
                    CGContextStrokePath(ctx);
                }
            }
            if ([self.delegate respondsToSelector:@selector(chart:didEndDrawChartWithColors:)]) {
                [self.delegate chart:self didEndDrawChartWithColors:self.colors];
            }
            if (!self.hideBottomDesc) {
                [self addBottomDescInLineOrHeap];
            }
            
            
            
        }
    }
    
}

/**
 堆叠图
 */
-(void)drawHeapInRect:(CGRect)rect{
    //这里面默认维度最大为3
    if([self.dataSource respondsToSelector:@selector(XTitleInWJChart:)]){
        NSArray *Xtitle = [self.dataSource XTitleInWJChart:self];
        NSArray *colorArr=Xtitle[Xtitle.count-1];
        NSUInteger colorCount=colorArr.count;
        self.colorCount=colorCount;
        NSUInteger Xcount=1;
        NSUInteger topCount=1;
        for (int i=0; i<Xtitle.count-1; i++) {
            NSArray *arr=Xtitle[i];
            if(Xtitle.count==3&&i==0){
                topCount=arr.count;
            }
            Xcount*=arr.count;
        }
        //        NSLog(@"---%zd,Xcount=%zd,%zd",colorCount,Xcount,topCount);
        
        if(Xtitle.count==3){
            NSArray *top=Xtitle[0];
            for (int i=0; i<topCount; i++) {
                UILabel *toptitle=[[UILabel alloc]initWithFrame:CGRectMake(i*rect.size.width/topCount, 0, rect.size.width/topCount, 30)];
                toptitle.textAlignment=NSTextAlignmentCenter;
                [self addSubview:toptitle];
                toptitle.text=top[i];
                toptitle.backgroundColor=WJRandomColor;
            }
        }
        
        //添加下方的label
        CGFloat oneTotalW = rect.size.width/Xcount;
        CGFloat bottomH=50+contentDescViewH;
        //计算堆叠后，每一列的最大值
        NSMutableArray *numArr=[NSMutableArray array];
        for (int i=0; i<Xcount; i++) {
            double num = 0;
            for (int j=0; j<colorCount; j++) {
                NSUInteger valueIndex=i*colorCount+j;
                num+=[self.Values[valueIndex] doubleValue];
            }
            [numArr addObject:[NSNumber numberWithDouble:num]];
        }
        CGFloat max=[numArr[0] doubleValue];
        for (NSNumber *num in numArr) {
            max=max<[num doubleValue]?[num doubleValue]:max;
        }
        CGFloat oneTotalH = (rect.size.height-bottomH-35)/(max/100.0);
        
        
        NSArray *arr=Xtitle.count>1?Xtitle[Xtitle.count-2]:Xtitle[0];
        if(Xtitle.count>1){
            for (NSUInteger i=0; i<Xcount; i++) {
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(i*oneTotalW, rect.size.height-bottomH, oneTotalW, 30)];
                label.textAlignment=NSTextAlignmentCenter;
                label.font=[UIFont systemFontOfSize:13];
                label.backgroundColor=[UIColor clearColor];
                label.text=arr[i%arr.count];
                [self addSubview:label];
            }
        }
        //画图
        CGFloat x = 0;
        CGFloat w = oneTotalW>HeapMaxWight?HeapMaxWight*3/5:oneTotalW*3/5;
        CGFloat h = 0;
        CGFloat y = 0;
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        for (NSUInteger i=0; i<Xcount; i++) {
            //记录上一个高度累加
            float preHeight=0;
            for (NSUInteger j=0; j<colorCount; j++) {
                //每一个值的下标
                NSUInteger valueIndex=i*colorCount+j;
                h = ([self.Values[valueIndex] floatValue]/100.0)*oneTotalH;
                x = i*oneTotalW+(oneTotalW-w)/2;
                y=rect.size.height-(h+preHeight+bottomH);
                preHeight+=h;
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
                CGContextAddPath(ctx, path.CGPath);
                UIColor *color=nil;
                if(i==0){
                    color=WJRandomColor;
                    [self.colors addObject:color];
                }else{
                    color=self.colors[j];
                }
                [color set];
                CGContextFillPath(ctx);
                [self.chartFrame addObject:[NSValue valueWithCGRect:CGRectMake(x, y, w, h)]];
            }
        }
        if ([self.delegate respondsToSelector:@selector(chart:didEndDrawChartWithColors:)]) {
            [self.delegate chart:self didEndDrawChartWithColors:self.colors];
        }
        
        if (!self.hideBottomDesc) {
            [self addBottomDescInLineOrHeap];
        }
        
        
    }
    
}

/**
 水平图
 */
-(void)drawHorizontalViewInRect:(CGRect)rect{
    if([self.dataSource respondsToSelector:@selector(XTitleInWJChart:)]){
        
        NSArray *Xtitle = [self.dataSource XTitleInWJChart:self];
        //一个描述的宽度
        CGFloat oneDescW=rect.size.width/2/Xtitle.count;
        int tableCount=1;
        //记录最后一列的frame
        NSMutableArray *lastViewFrames=[NSMutableArray array];
        for (int i=0; i<Xtitle.count; i++) {
            NSArray *category=Xtitle[i];
            NSArray *preCategory=nil;
            if(i>0){
                preCategory=Xtitle[i-1];
            }
            tableCount*=(preCategory.count?preCategory.count:1);
            CGFloat oneDescH=(rect.size.height-contentDescViewH)/category.count/tableCount;
            for (int j=0;j<category.count*tableCount;j++) {
                NSString *name = category[j%category.count];
                UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(i*oneDescW, j*oneDescH, oneDescW, oneDescH)];
                nameLabel.font=[UIFont systemFontOfSize:13];
                nameLabel.text=name;
                if(i==Xtitle.count-1){
                    double perValue=[self.Values[j] doubleValue];
                    nameLabel.text=[NSString stringWithFormat:@"%@   %.2f%%",name,perValue];
                    [lastViewFrames addObject:[NSValue valueWithCGRect:nameLabel.frame]];
                }
                nameLabel.textAlignment=NSTextAlignmentCenter;
                
                [self addSubview:nameLabel];
            }
            
        }
        
        //画图
        NSUInteger count = self.Values.count;
        CGFloat x = rect.size.width/2;
        CGFloat h = [lastViewFrames[0] CGRectValue].size.height*3/5;
        // 3/5
        if([lastViewFrames[0] CGRectValue].size.height > HorizonMaxHeight)
            h=HorizonMaxHeight*3/5;
        CGFloat y = 0;
        CGFloat w = 0;
        //找出最大的值
        CGFloat max=[self.Values[0] doubleValue];
        for (NSNumber *num in self.Values) {
            max=max<[num doubleValue]?[num doubleValue]:max;
        }
        CGFloat totalW = rect.size.width/2.0/(max/100.0);
        // 1.获取上下文
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        for (int i = 0; i < count; i++) {
            //灰色
            CGRect lastRect=[lastViewFrames[i] CGRectValue];
            //            w = totalW;
            //            y =(lastRect.size.height-h)/2.0+i*lastRect.size.height;
            //            UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
            //            CGContextAddPath(ctx, path1.CGPath);
            //            [[UIColor lightGrayColor] set];
            //            CGContextFillPath(ctx);
            //            [self.chartFrame addObject:[NSValue valueWithCGRect:CGRectMake(x, y, w, h)]];
            //蓝色
            w = totalW * [self.Values[i] floatValue] / 100.0;
            y =(lastRect.size.height-h)/2.0+i*lastRect.size.height;
            [self.chartFrame addObject:[NSValue valueWithCGRect:CGRectMake(x, y, w, h)]];
            UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
            CGContextAddPath(ctx, path2.CGPath);
            [[UIColor colorWithRed:0/255.0 green:100/255.0 blue:168/255.0 alpha:1] set];
            CGContextFillPath(ctx);
        }
    }
    
    //详细描述
    if ([self.delegate respondsToSelector:@selector(chart:didEndDrawChartWithColors:)]) {
        [self.delegate chart:self didEndDrawChartWithColors:self.colors];
    }
    
    if (self.hideBottomDesc) {
        return;
    }
    
    self.contentDescView.frame=CGRectMake(0, rect.size.height-contentDescViewH, rect.size.width, contentDescViewH);
    describeView *view=[[describeView alloc]init];
    view.colorView.backgroundColor=[UIColor colorWithRed:0/255.0 green:100/255.0 blue:168/255.0 alpha:1];
    view.desc.text=@"病例数";
    view.desc.font=[UIFont systemFontOfSize:12];
    
    view.frame = CGRectMake(0, 20, [view.desc.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width+25, 20);
    
    [self.contentDescView addSubview:view];
    self.contentDescView.contentSize=CGSizeMake(rect.size.width, contentDescViewH);
    
    
}

/**
 饼图
 */
-(void)drawPieInRect:(CGRect)rect{
    
    for (int i=0; i<self.Values.count; i++) {
        [self.colors addObject:WJRandomColor];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat centerX=rect.size.width/2.0;
    CGFloat centerY=(rect.size.height-contentDescViewH)/2.0;
    CGPoint pieCenter = CGPointMake(centerX, centerY);
    self.pieCenter=pieCenter;
    CGFloat pieRadius = (centerX>centerY?centerY:centerX)-5;
    self.pieRadius= pieRadius;
    double startA = 0;
    double angle = 0;
    double endA = 0;
    
    for (int i=0;i<self.Values.count;i++) {
        NSNumber *number = self.Values[i];
        startA = endA;
        angle = number.doubleValue / 100.0 * M_PI * 2;
        endA = startA + angle;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pieCenter radius:pieRadius startAngle:startA endAngle:endA clockwise:YES];
        [path addLineToPoint:pieCenter];
        UIColor *color=self.colors[i];
        [color set];
        CGContextAddPath(ctx, path.CGPath);
        CGContextFillPath(ctx);
    }
    if ([self.delegate respondsToSelector:@selector(chart:didEndDrawChartWithColors:)]) {
        [self.delegate chart:self didEndDrawChartWithColors:self.colors];
    }
    //详细描述()
    if (self.hideBottomDesc) {
        return;
    }
    
    self.contentDescView.frame=CGRectMake(0, rect.size.height-contentDescViewH, rect.size.width, contentDescViewH);
    CGFloat maxX=0;
    for (int i=0; i<self.Values.count; i++) {
        describeView *view=[[describeView alloc]init];
        view.colorView.backgroundColor=self.colors[i];
        if([self.dataSource respondsToSelector:@selector(chart:titleForValueAtIndex:)]){
            view.desc.text=[self.dataSource chart:self titleForValueAtIndex:i];
        }
        view.desc.font=[UIFont systemFontOfSize:12];
        view.frame = CGRectMake(maxX, 20, [view.desc.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width+25, 20);
        
        maxX+=view.frame.size.width+10;
        
        [self.contentDescView addSubview:view];
    }
    self.contentDescView.contentSize=CGSizeMake(maxX, 20);
    
    
    
}
#pragma mark - touch Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    switch (self.chartType) {
        case ChartTypePie:
            [self touchPieWithPoint:point];
            break;
        case ChartTypeHorizon:
            [self touchHorizontalViewWithPoint:point];
            break;
        case ChartTypeHeap:
            [self touchHeapWithPoint:point];
            break;
        case ChartTypeLine:
            [self touchLineWithPoint:point];
            break;
        default:
            break;
    }
}
-(void)touchLineWithPoint:(CGPoint)point{
    [self touchHeapWithPoint:point];
}
-(void)touchHeapWithPoint:(CGPoint)point{
    for (int i=0 ; i<self.chartFrame.count; i++) {
        
        if(CGRectContainsPoint([self.chartFrame[i] CGRectValue], point)){
            
            self.selectedColor = self.colors[i%self.colorCount];
            
            if([self.delegate respondsToSelector:@selector(chart:didSelectAtIndex:)]){
                [self.delegate chart:self didSelectAtIndex:i];
            }
            CGRect rect = [self.chartFrame[i] CGRectValue];
            if(self.coverRectView==nil){
                UIView *coverRectView=[[UIView alloc]initWithFrame:CGRectMake(rect.origin.x-3, rect.origin.y-2, rect.size.width+6, rect.size.height+4)];
                self.coverRectView=coverRectView;
                coverRectView.alpha=0.5;
                coverRectView.backgroundColor=[UIColor whiteColor];
                [self addSubview:coverRectView];
                
            }else{
                self.coverRectView.frame=CGRectMake(rect.origin.x-3, rect.origin.y-2, rect.size.width+6, rect.size.height+4);
            }
            break;
        }
    }
}
-(void)touchHorizontalViewWithPoint:(CGPoint)point{
    UIColor *color = [UIColor colorWithRed:0/255.0 green:100/255.0 blue:168/255.0 alpha:1];// 居然是空的
    self.selectedColor = color ;
    for (int i=0 ; i<self.chartFrame.count; i++) {
        
        if(CGRectContainsPoint([self.chartFrame[i] CGRectValue], point)){
            if([self.delegate respondsToSelector:@selector(chart:didSelectAtIndex:)]){
                [self.delegate chart:self didSelectAtIndex:i];
            }
            CGRect rect = [self.chartFrame[i] CGRectValue];
            if(self.coverRectView==nil){
                UIView *coverRectView=[[UIView alloc]initWithFrame:CGRectMake(rect.origin.x-3, rect.origin.y-2, rect.size.width+6, rect.size.height+4)];
                self.coverRectView=coverRectView;
                coverRectView.alpha=0.5;
                coverRectView.backgroundColor=[UIColor whiteColor];
                [self addSubview:coverRectView];
                
            }else{
                self.coverRectView.frame=CGRectMake(rect.origin.x-3, rect.origin.y-2, rect.size.width+6, rect.size.height+4);
            }
            break;
        }
    }
}
-(void)touchPieWithPoint:(CGPoint)point{
    if([self distanceFromPointX:self.pieCenter toPointY:point]<self.pieRadius){
        
        double x=atan((point.y-self.pieCenter.y)/(point.x-self.pieCenter.x));
        double angle=(x*360)/(2.0*M_PI);
        if(point.x>=self.pieCenter.x){
            
            if(angle<0){
                angle=360+angle;
            }
        }else{
            angle=180+angle;
            
        }
        double Angle=0;
        for (int i=0; i<self.Values.count; i++) {
            
            NSNumber *number = self.Values[i];
            
            Angle+=number.doubleValue/100*360;
            
            if(angle<Angle){
                self.selectedColor = self.colors[i];
                if([self.delegate respondsToSelector:@selector(chart:didSelectAtIndex:)]){
                    [self.delegate chart:self didSelectAtIndex:i];
                }
                if(self.coverPieImage==nil){
                    UIImageView *coverPieImage=[[UIImageView alloc]init];
                    self.coverPieImage=coverPieImage;
                    coverPieImage.frame = (CGRect){0,0,{self.pieRadius*2+10, self.pieRadius*2+10}};
                    coverPieImage.center = self.pieCenter;
                    coverPieImage.backgroundColor=[UIColor clearColor];
                    [self addSubview:coverPieImage];
                }
                UIGraphicsBeginImageContextWithOptions(self.coverPieImage.frame.size, NO, 1);
                CGContextRef context=UIGraphicsGetCurrentContext();
                double startA = 0;
                double angle = 0;
                double endA = 0;
                for (int j=0;j<i+1;j++) {
                    NSNumber *number = self.Values[j];
                    startA = endA;
                    angle = number.doubleValue / 100.0 * M_PI * 2;
                    endA = startA + angle;
                }
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.pieRadius+5,self.pieRadius+5) radius:self.pieRadius+5 startAngle:startA endAngle:endA clockwise:YES];
                [path addLineToPoint:CGPointMake(self.pieRadius+5, self.pieRadius+5)];
                CGContextAddPath(context, path.CGPath);
                [[UIColor colorWithRed:1 green:1 blue:1  alpha:0.7]set];
                CGContextFillPath(context);
                UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
                self.coverPieImage.image=image;
                return;
            }
        }
        
    }
    
}


#pragma mark - other

/**
 * 折线图or 堆叠图上的底部
 */
-(void)addBottomDescInLineOrHeap{
    
    NSArray *Xtitle = [self.dataSource XTitleInWJChart:self];
    //详细描述()
    self.contentDescView.frame=CGRectMake(0, self.frame.size.height-contentDescViewH, self.frame.size.width, contentDescViewH);
    CGFloat maxX=0;
    NSArray *names=Xtitle[Xtitle.count-1];
    for (int i=0; i<self.colors.count; i++) {
        describeView *view=[[describeView alloc]init];
        view.colorView.backgroundColor=self.colors[i];
        view.desc.text=names[i];
        view.desc.font=[UIFont systemFontOfSize:12];
        view.frame = CGRectMake(maxX, 20, [view.desc.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width+25, 20);
        
        
        maxX+=view.frame.size.width+10;
        [self.contentDescView addSubview:view];
        
    }
    self.contentDescView.contentSize=CGSizeMake(maxX, 20);
    
}

-(float)distanceFromPointX:(CGPoint)start toPointY:(CGPoint)end{
    float distance;
    
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

@end
