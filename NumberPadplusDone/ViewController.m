//
//  ViewController.m
//  NumberPadplusDone
//
//  Created by InoueTaisuke on 2013/09/23.
//  Copyright (c) 2013年 Taisuke Inoue. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // デリゲートを指定
    uitf.delegate = self;
    
    // キーボードの通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // フォーカスをセットする
    [uitf becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//指定したUIColorでCGRectの大きさを塗り潰したUIImageを返す
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)keyboardWillShow:(NSNotification*)note
{
    // ボタン作成＋設定
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor colorWithRed:0.0f green:0.51f blue:1.0f alpha:1.0f]];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [doneButton setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    
    // ボタンが押されたとき (Touch Up Inside) に enterButton: メソッドが呼び出されるようにします。
    [doneButton addTarget:self action:@selector(enterButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // ボタンを表示させるウィンドウはアプリケーションの 2 番目 (Index=1) のウィンドウで良さそうでした。
    UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    
    // キーボードの位置と、表示時間を NSNotification の userInfo から取得します。
    CGRect keyboardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat Curve = [[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] doubleValue];
    
    // 画面サイズを取得
    CGRect fullScreenRect = [UIScreen mainScreen].bounds;
    // キーボードのスライド表示に似せるため、移動前 (startFrame) と移動後 (fixedFrame) の 2 つの位置を用意しました。
    CGRect startFrame = CGRectMake(0.0f, (fullScreenRect.size.height-53) + CGRectGetHeight(keyboardFrame), 105.0f, 53.0f);
    
    CGRect fixedFrame;
    
    // iosによって微妙にサイズが変わるので調整
    if ( [[[UIDevice currentDevice] systemVersion] integerValue] >= 7 )
        fixedFrame = CGRectMake(0.0f, (fullScreenRect.size.height - 53.5f), 104.5f, 53.5f);
    else
        fixedFrame = CGRectMake(0.0f, (fullScreenRect.size.height - 53), 105.0f, 53.0f);
    
    // ボタンをアニメーションで表示させるために、まずは最初の場所（画面外）に表示されるように frame を設定します。
    doneButton.frame = startFrame;
    // ボタンは 1 番目 (Index=0) のサブビューとして追加しないと、角が丸く切り抜かれない場合があるようでした。
    [window insertSubview:doneButton atIndex:0];
    // 適切な位置へボタンが移動するように、アニメーションを設定します。
    [UIView beginAnimations:@"showKeyboardButton" context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:Curve];
    doneButton.frame = fixedFrame;
    [UIView commitAnimations];
    
}

-(void)enterButton:(UIButton*)sender
{
    // 標準キーボードを非表示にします。
    [self.view endEditing:YES];
    // 自前の Enter キーをアニメーションで、キーボードと一緒に画面外へ移動します。
    [UIView beginAnimations:@"hideKeyboardButton" context:NULL];
    [UIView setAnimationDuration:0.25f];
    sender.frame = CGRectMake(0.0f, ([UIScreen mainScreen].bounds.size.height - sender.frame.size.height) + 216.0f, 104.0f, 53.0f);
    [UIView commitAnimations];
    // キーボードが消え終わった頃合い（ここでは 0.3 秒後）で、自前の Enter キーを解放します。
    [sender performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3f];
}

@end
