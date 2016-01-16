//
//  SignupViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController()
@end

@implementation SignupViewController

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
    title.text= @"Signup";
    [self.view addSubview:title];
    
    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    signupTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    signupTableView.backgroundColor= [UIColor whiteColor];
    signupTableView.delegate= self;
    signupTableView.dataSource= self;
    signupTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:signupTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 4;
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
    
    else if(indexPath.row== 2) {
        if(confirmCell== nil) { confirmCell= [[TextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; }
        confirmCell.label.text= @"Confirm"; confirmCell.textField.secureTextEntry= YES; confirmCell.textField.placeholder= @"Required";
        return confirmCell;
    }
    
    static NSString *ButtonCellIdentifier= @"NormalCell";
    ButtonCell *buttonCell= [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if(buttonCell== nil) { buttonCell= [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier]; }
    buttonCell.label.text= @"SUBMIT";
    return buttonCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row== 0) { [usernameCell showTextFieldKeyboard]; [passwordCell hideTextFieldKeyboard]; [confirmCell hideTextFieldKeyboard]; }
    else if(indexPath.row== 1) { [usernameCell hideTextFieldKeyboard]; [passwordCell showTextFieldKeyboard]; [confirmCell hideTextFieldKeyboard]; }
    else if(indexPath.row== 2) { [usernameCell hideTextFieldKeyboard]; [passwordCell hideTextFieldKeyboard]; [confirmCell showTextFieldKeyboard]; }
    else {
        if([usernameCell.textField.text isEqualToString:@""] || [passwordCell.textField.text isEqualToString:@""]) { NSLog(@"PLEASE CHECK. SOME FIELDS ARE EMPTY"); return; }
        if(![passwordCell.textField.text isEqualToString:confirmCell.textField.text]) { NSLog(@"PLEASE CHECK. PASSWORD AND CONFIRM PASSWORD DIFFERS"); return; }
        
        NSString *username= [usernameCell.textField.text lowercaseString];
        NSString *password= passwordCell.textField.text;
        [[self appDelegate].cloudilly createGroup:username WithPassword:password WithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
            NSLog(@"@@@@@@ CREATE");
            NSLog(@"%@", dict);
            [[self appDelegate].cloudilly loginToUsername:username WithPassword:password WithCallback:^(NSDictionary *dict) {
                if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
                NSLog(@"@@@@@@ LOGIN");
                NSLog(@"%@", dict);
                
                NSMutableDictionary *dictProfile= [[NSMutableDictionary alloc] init];
                [dictProfile setObject:username forKey:@"username"];
                [dictProfile setObject:password forKey:@"password"];
                [[self appDelegate].database updateProfile:dictProfile];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSignupView" object:nil];
                
                Profile *profile= [[self appDelegate].database fetchProfile];
                [[self appDelegate].cloudilly registerApns:profile.token WithCallback:^(NSDictionary *dict) {
                    if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
                    NSLog(@"@@@@@@ REGISTER");
                    NSLog(@"%@", dict);
                }];
            }];
        }];
    }
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSignupView" object:nil];
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end