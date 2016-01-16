//
//  LoginViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController()
@end

@implementation LoginViewController

-(id)init {
    self= [super init];
    if(self) {
    }
    return self;
}

-(void)loadView {
    width= [[UIScreen mainScreen] bounds].size.width;
    height= [[UIScreen mainScreen] bounds].size.height;
    self.view= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    self.view.backgroundColor= [UIColor whiteColor];
    
    UIView *status= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 20.0)];
    status.backgroundColor= [UIColor blackColor];
    [self.view addSubview:status];
    
    UIView *top= [[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, width, 50.0)];
    top.backgroundColor= [UIColor blackColor];
    [self.view addSubview:top];
    
    UILabel *title= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 26.0, width, 36.0)];
    title.font= [UIFont fontWithName:@"ChalkboardSE-Bold" size:22.0];
    title.backgroundColor= [UIColor clearColor];
    title.textAlignment= NSTextAlignmentCenter;
    title.textColor= [UIColor whiteColor];
    title.text= @"Login";
    [self.view addSubview:title];
    
    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    loginTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    loginTableView.backgroundColor= [UIColor whiteColor];
    loginTableView.delegate= self;
    loginTableView.dataSource= self;
    loginTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:loginTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row== 0) {
        if(usernameCell== nil) { usernameCell= [[TextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; }
        usernameCell.label.text= @"Username"; usernameCell.textField.placeholder= @"Required";
        return usernameCell;
    }
    
    else if(indexPath.row== 1) {
        if(passwordCell== nil) { passwordCell= [[TextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; }
        passwordCell.label.text= @"Password"; passwordCell.textField.secureTextEntry= YES; passwordCell.textField.placeholder= @"Required";
        return passwordCell;
    }
    
    static NSString *ButtonCellIdentifier= @"NormalCell";
    ButtonCell *buttonCell= [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if(buttonCell== nil) { buttonCell= [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier]; }
    buttonCell.label.text= @"SUBMIT";
    return buttonCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row== 0) { [usernameCell showTextFieldKeyboard]; [passwordCell hideTextFieldKeyboard]; }
    else if(indexPath.row== 1) { [usernameCell hideTextFieldKeyboard]; [passwordCell showTextFieldKeyboard]; }
    else if(indexPath.row== 2) {
        [usernameCell hideTextFieldKeyboard];
        [passwordCell hideTextFieldKeyboard];
        if([usernameCell.textField.text isEqualToString:@""] || [passwordCell.textField.text isEqualToString:@""]) {
            [[self appDelegate] alertTitle:@"ERROR" AndMessage:@"PLEASE CHECK. SOME FIELDS ARE EMPTY"]; return;
        }
        
        NSString *username= [usernameCell.textField.text lowercaseString];
        NSString *password= passwordCell.textField.text;
        [[self appDelegate].cloudilly loginToUsername:username WithPassword:password WithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
            NSLog(@"@@@@@@ LOGIN");
            NSLog(@"%@", dict);
            
            NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
            [dictProfile setObject:username forKey:@"username"];
            [dictProfile setObject:password forKey:@"password"];
            [[self appDelegate].database updateProfile:dictProfile];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoginView" object:nil];
            
            Profile *profile= [[self appDelegate].database fetchProfile];
            [[self appDelegate].cloudilly registerApns:profile.token WithCallback:^(NSDictionary *dict) {
                if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
                NSLog(@"@@@@@@ REGISTER");
                NSLog(@"%@", dict);
            }];
        }];
    }
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoginView" object:nil];
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end