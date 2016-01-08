//
//  SettingsViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 16/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController()
@end

@implementation SettingsViewController

-(id)init {
    self= [super init];
    if(self) {
        profileFetchedResultsController= [self profileFetchedResultsController];
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
    title.text= @"Settings";
    [self.view addSubview:title];

    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    settingsTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    settingsTableView.backgroundColor= [UIColor whiteColor];
    settingsTableView.delegate= self;
    settingsTableView.dataSource= self;
    settingsTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:settingsTableView];
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
    [settingsTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Profile *profile= [[self appDelegate].database fetchProfile];
    if(indexPath.row== 0) {
        static NSString *TitleCellIdentifier= @"TitleCell";
        TitleCell *titleCell= [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if(titleCell== nil) { titleCell= [[TitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier]; }
        titleCell.label.text= profile.username ? profile.username : @"Not logged in";
        return titleCell;
    }
    
    static NSString *NormalCellIdentifier= @"NormalCell";
    NormalCell *normalCell= [tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
    if(normalCell== nil) { normalCell= [[NormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier]; }
    if(indexPath.row== 1) { normalCell.label.text= profile.username ? @"Logout" : @"Login"; }
    else if(indexPath.row== 2) { normalCell.label.text= profile.username ? @"Pair with DingDong" : @"Sign Up"; }
    else if(indexPath.row== 3) { normalCell.label.text= @"Terms Of Service"; }
    else if(indexPath.row== 4) { normalCell.label.text= @"Privacy Policy"; }
    return normalCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Profile *profile= [[self appDelegate].database fetchProfile];
    if(indexPath.row== 1) { profile.username ? [self fireLogout] : [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoginView" object:nil]; }
    else if(indexPath.row== 2) {
        profile.username ?
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showPairView" object:nil] :
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showSignupView" object:nil];
    }
    else if(indexPath.row== 3) { NSLog(@"TERMS OF SERVICE"); }
    else if(indexPath.row== 4) { NSLog(@"PRIVACY POLICY"); }
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSettingsView" object:nil];
}

-(void)fireLogout {
    [[self appDelegate].cloudilly logoutWithCallback:^(NSDictionary *dict) {
        if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
        NSLog(@"@@@@@@ LOGOUT");
        NSLog(@"%@", dict);
        [[self appDelegate].database resetProfile];
        [[self appDelegate].database deleteDingdongs];
        
        [[self appDelegate].cloudilly unregisterApnsWithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
            NSLog(@"@@@@@@ UNREGISTER");
            NSLog(@"%@", dict);
        }];
    }];
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end