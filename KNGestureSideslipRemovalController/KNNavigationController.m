//
//  KNNavigationController.m
//  KNGestureSideslipRemovalController
//
//  Created by devzkn on 02/04/2017.
//  Copyright © 2017 hisun. All rights reserved.
//

#import "KNNavigationController.h"

@interface KNNavigationController ()

/**
 保持push 控制器 界面的截图数据
 */
@property (nonatomic,strong) NSMutableArray *images;

@property (nonatomic,strong) UIImageView *imagesView;
@property (nonatomic,strong) UIView *cover;


@end

@implementation KNNavigationController


- (UIImageView *)imagesView{
    if (_imagesView == nil) {
        UIImageView *imgView = [[UIImageView alloc]init];
        [imgView setFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _imagesView = imgView;
        
    }
    return _imagesView;
}

- (UIView *)cover{
    
    if (_cover == nil) {
        
        
        UIView *cover = [[UIView alloc]initWithFrame:self.imagesView.frame];
        cover.alpha = 0.5;
        cover.backgroundColor = [UIColor blackColor];
        _cover = cover;
        
    }
    return _cover;
}

- (NSMutableArray *)images{
    
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIPanGestureRecognizer *panGestureRecognizer= [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(draggingPanGestureRecognizer:)];
    
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
}


- (void)draggingPanGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer{
    
    //移除控制器
    if (self.viewControllers.count <=1) {
        return;
    }

   CGFloat tx = [panGestureRecognizer translationInView:self.view].x;
    
    if (tx<0) {
        return;//不处理往左边拖拽的动作
    }
    //1. 显示上一个控制器的图片，即添加图片到窗口
    
    if (self.images.count<=1) {
        return;
    }
   
    
    
//    NSLog(@"%ld", (long)panGestureRecognizer.state);
    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled){//处理手势离开屏幕的那一刻              //保证一个控制器只pop  一次
        
        
        //控制器移除条件
        if (self.view.frame.origin.x > self.view.bounds.size.width*0.5) {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0) ;

            }completion:^(BOOL finished) {
                
                [self.images removeLastObject];
                //隐藏地步控件，并移除对应的数据源
                [self.imagesView removeFromSuperview];
                [self.cover removeFromSuperview];
                [self popViewControllerAnimated:YES];
                self.view.transform = CGAffineTransformIdentity;
            }];
            
            
          

            
        }else{
            //还原
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformIdentity;
                
            }];
        }
        
        
    }else{
        
        [self.imagesView setImage: self.images[self.images.count -2]];
        [[UIApplication sharedApplication].keyWindow insertSubview:self.imagesView atIndex:0];
        [[UIApplication sharedApplication].keyWindow insertSubview:self.cover aboveSubview:self.imagesView];
        self.view.transform = CGAffineTransformMakeTranslation(tx, 0) ;

    }
    
    
    
    
}




- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    
    [super pushViewController:viewController animated:animated ];
    
    [self screenshot];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.images.count==0) {
        [self screenshot];
    }
    
}

- (void)screenshot{
    //截图
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);// yes 表示不透明  If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.  size  表示图片的截取范围
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//获取当前的上下文
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //    [UIImagePNGRepresentation(image) writeToFile:@"/Users/devzkn/Desktop/1kevin.png" atomically:YES];
    [self.images addObject:image];
    
}

@end
