//
//  MainViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController()
@end

@implementation MainViewController

-(id)init {
    self= [super init];
    if(self) {
        self.tasks= [[NSMutableDictionary alloc] init];
        NSMutableDictionary *task= [[NSMutableDictionary alloc] init];
        [task setObject:@"nothing" forKey:@"task"];
        [self.tasks setObject:task forKey:@"dingdong"];
        self.taskTimer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
        profileFetchedResultsController= [self profileFetchedResultsController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSettingsView:) name:@"showSettingsView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSettingsView:) name:@"hideSettingsView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignupView:) name:@"showSignupView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSignupView:) name:@"hideSignupView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView:) name:@"showLoginView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoginView:) name:@"hideLoginView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPairView:) name:@"showPairView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePairView:) name:@"hidePairView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBeaconView:) name:@"showBeaconView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBeaconView:) name:@"hideBeaconView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageView:) name:@"showMessageView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMessageView:) name:@"hideMessageView" object:nil];
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
    title.text= @"DingDong";
    [self.view addSubview:title];
    
    UIButton *settingBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn addTarget:self action:@selector(fireSettings) forControlEvents:UIControlEventTouchUpInside];
    settingBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [settingBtn setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
    [self.view addSubview:settingBtn];

    UIButton *beaconBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [beaconBtn addTarget:self action:@selector(fireBeacon) forControlEvents:UIControlEventTouchUpInside];
    beaconBtn.frame= CGRectMake(width- 50.0, 20.0, 50.0, 50.0);
    [beaconBtn setImage:[UIImage imageNamed:@"Beacon"] forState:UIControlStateNormal];
    [self.view addSubview:beaconBtn];
    
    dingdongBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    dingdongBtn.titleLabel.lineBreakMode= NSLineBreakByWordWrapping;
    dingdongBtn.titleLabel.textAlignment= NSTextAlignmentCenter;
    [dingdongBtn setTitle:@"No\nDingDong\nnearby" forState:UIControlStateNormal];
    [dingdongBtn.titleLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:22.0]];
    [dingdongBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dingdongBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [dingdongBtn addTarget:self action:@selector(fireDingdong) forControlEvents:UIControlEventTouchUpInside];
    dingdongBtn.frame= CGRectMake((width- 250.0)/ 2, height/2- 125.0+ 20.0, 250.0, 250.0);
    dingdongBtn.clipsToBounds= YES;
    dingdongBtn.layer.cornerRadius= 125.0;
    dingdongBtn.backgroundColor= [UIColor blackColor];
    [self.view addSubview:dingdongBtn];
}

-(NSFetchedResultsController *)profileFetchedResultsController {
    NSManagedObjectContext *context= [[self appDelegate].database managedObjectContext];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:context];
    NSSortDescriptor *sort= [[NSSortDescriptor alloc] initWithKey:@"nearby" ascending:YES];
    NSArray *sortDescriptors= [NSArray arrayWithObjects:sort, nil]; NSFetchRequest *request= [[NSFetchRequest alloc] init];
    request.entity= entity; request.sortDescriptors= sortDescriptors;
    profileFetchedResultsController= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    profileFetchedResultsController.delegate= self; [profileFetchedResultsController performFetch:nil];
    return profileFetchedResultsController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    Profile *profile= [[self appDelegate].database fetchProfile];
    NSMutableDictionary *task= [[NSMutableDictionary alloc] init];
    if([profile.nearby isEqualToString:@""]) { [task setObject:@"nothing" forKey:@"task"]; }
    else { [task setObject:@"nearby" forKey:@"task"]; [task setObject:profile.nearby forKey:@"value"]; }
    [self.tasks setObject:task forKey:@"dingdong"];
}

-(void)fireTimer {
    NSArray *tasks= [self.tasks allKeys];
    int random= arc4random() % [tasks count];
    self.currentTask= [tasks objectAtIndex:random];
    NSMutableDictionary *dictTask= [self.tasks objectForKey:self.currentTask];
    
    NSString *task= [dictTask objectForKey:@"task"];
    NSString *value= [dictTask objectForKey:@"value"];
    if([task isEqualToString:@"nothing"]) {
        [dingdongBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dingdongBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        dingdongBtn.backgroundColor= [UIColor blackColor];
        [dingdongBtn setTitle:@"No\nDingDong\nnearby" forState:UIControlStateNormal];
    }
    else if([task isEqualToString:@"nearby"]) {
        [dingdongBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dingdongBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        dingdongBtn.backgroundColor= [UIColor blackColor];
        [dingdongBtn setTitle:[NSString stringWithFormat:@"#%@\nPress to DingDong", value] forState:UIControlStateNormal];
    }
    else if([task isEqualToString:@"visitor"]) {
        [dingdongBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dingdongBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        dingdongBtn.backgroundColor= [UIColor lightGrayColor];
        [dingdongBtn setTitle:[NSString stringWithFormat:@"Visitor at #%@\nPress to answer", value] forState:UIControlStateNormal];
    }
    else if([task isEqualToString:@"waiting"]) {
        [dingdongBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dingdongBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        dingdongBtn.backgroundColor= [UIColor lightGrayColor];
        [dingdongBtn setTitle:[NSString stringWithFormat:@"Waiting for\n#%@ to answer", value] forState:UIControlStateNormal];
    }
}

-(void)fireSettings {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSettingsView" object:nil];
}

-(void)fireBeacon {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBeaconView" object:nil];
}

-(void)fireDingdong {
    NSMutableDictionary *dictTask= [self.tasks objectForKey:self.currentTask];
    NSString *task= [dictTask objectForKey:@"task"];
    NSString *value= [dictTask objectForKey:@"value"];
    if([task isEqualToString:@"nothing"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:@"NO DINGDONG NEARBY"]; }
    else if([task isEqualToString:@"nearby"]) { [self fireNotify:value]; }
    else if([task isEqualToString:@"visitor"]) {
        NSMutableDictionary *dictUserInfo= [[NSMutableDictionary alloc] init];
        [dictUserInfo setObject:value forKey:@"recipient"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessageView" object:nil userInfo:dictUserInfo];
    }
    else if([task isEqualToString:@"waiting"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:@"OUCH"]; }
}

-(void)fireNotify:(NSString *)dingdong {
    Profile *profile= [[self appDelegate].database fetchProfile];
    if(!profile.username) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:@"PLEASE LOGIN FIRST"]; return; }
    
    [[self appDelegate].cloudilly notify:@"DingDong" Group:[NSString stringWithFormat:@"dingdong:%@", dingdong] WithCallback:^(NSDictionary *dict) {
        if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
        NSLog(@"@@@@@@ NOTIFY");
        NSLog(@"%@", dict);
        
        [[self appDelegate].cloudilly joinGroup:dingdong WithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { NSLog(@"ERROR %@", dict); }
            NSLog(@"@@@@@@ JOIN");
            NSLog(@"%@", dict);
            
            NSMutableDictionary *payload= [[NSMutableDictionary alloc] init];
            [payload setObject:@"DingDong" forKey:@"message"];
            [[self appDelegate].cloudilly postGroup:dingdong WithPayload:payload WithCallback:^(NSDictionary *dict) {
                if([[dict objectForKey:@"status"] isEqual: @"fail"]) { NSLog(@"ERROR %@", dict); return; }
                NSLog(@"@@@@@@ POST");
                NSLog(@"%@", dict);
            }];
        }];
    }];
    
    NSMutableDictionary *task= [[NSMutableDictionary alloc] init];
    [task setObject:@"waiting" forKey:@"task"];
    [task setObject:dingdong forKey:@"value"];
    NSString *key= [NSString stringWithFormat:@"WAITING:%@", dingdong];
    [self.tasks setObject:task forKey:key];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tasks removeObjectForKey:key];
    });
}

-(void)showSettingsView:(NSNotification *)notification {
    self.settingsViewController= [[SettingsViewController alloc] init];
    [self.view addSubview:self.settingsViewController.view];
}

-(void)hideSettingsView:(NSNotification *)notification {
    [self.settingsViewController.view removeFromSuperview];
    self.settingsViewController= nil;
}

-(void)showSignupView:(NSNotification *)notification {
    self.signupViewController= [[SignupViewController alloc] init];
    [self.view addSubview:self.signupViewController.view];
}

-(void)hideSignupView:(NSNotification *)notification {
    [self.signupViewController.view removeFromSuperview];
    self.signupViewController= nil;
}

-(void)showLoginView:(NSNotification *)notification {
    self.loginViewController= [[LoginViewController alloc] init];
    [self.view addSubview:self.loginViewController.view];
}

-(void)hideLoginView:(NSNotification *)notification {
    [self.loginViewController.view removeFromSuperview];
    self.loginViewController= nil;
}

-(void)showPairView:(NSNotification *)notification {
    self.pairViewController= [[PairViewController alloc] init];
    [self.view addSubview:self.pairViewController.view];
}

-(void)hidePairView:(NSNotification *)notification {
    [self.pairViewController.view removeFromSuperview];
    self.pairViewController= nil;
}

-(void)showBeaconView:(NSNotification *)notification {
    self.beaconViewController= [[BeaconViewController alloc] init];
    [self.view addSubview:self.beaconViewController.view];
}

-(void)hideBeaconView:(NSNotification *)notification {
    [self.beaconViewController.view removeFromSuperview];
    self.beaconViewController= nil;
}

-(void)showMessageView:(NSNotification *)notification {
    self.messageViewController= [[MessageViewController alloc] initWithRecipient:[notification.userInfo objectForKey:@"recipient"]];
    [self.view addSubview:self.messageViewController.view];
}

-(void)hideMessageView:(NSNotification *)notification {
    [self.messageViewController.view removeFromSuperview];
    self.messageViewController= nil;
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end