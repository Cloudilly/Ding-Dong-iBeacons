//
//  PairViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 17/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "PairViewController.h"

@interface PairViewController()
@end

@implementation PairViewController

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
    title.text= @"Pair with DingDong";
    [self.view addSubview:title];
    
    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];

    pairTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    pairTableView.backgroundColor= [UIColor whiteColor];
    pairTableView.delegate= self;
    pairTableView.dataSource= self;
    pairTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:pairTableView];
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
    [pairTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    Profile *profile= [profileFetchedResultsController.fetchedObjects objectAtIndex:0];
    return [profile.nearby isEqualToString:@""] ? 1 : 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row== 0) {
        static NSString *TitleCellIdentifier= @"TitleCell";
        TitleCell *titleCell= [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if(titleCell== nil) { titleCell= [[TitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier]; }
        Profile *profile= [[self appDelegate].database fetchProfile];
        titleCell.label.text= [profile.nearby isEqualToString:@""] ? @"No DingDong nearby" : @"Pair mobile device with nearest DingDong";
        return titleCell;
    }
    
    else if(indexPath.row== 1) {
        static NSString *NormalCellIdentifier= @"NormalCell";
        NormalCell *normalCell= [tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
        if(normalCell== nil) { normalCell= [[NormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier]; }
        normalCell.label.text= @"Beacon S/N";
        if(profileFetchedResultsController.fetchedObjects.count> 0) {
            Profile *profile= [profileFetchedResultsController.fetchedObjects objectAtIndex:0];
            normalCell.value.text= profile.nearby;
        }
        return normalCell;
    }
    
    else if(indexPath.row== 2) {
        if(tokenCell== nil) { tokenCell= [[TextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; }
        tokenCell.label.text= @"Token"; tokenCell.textField.placeholder= @"Required";
        return tokenCell;
    }
    
    static NSString *ButtonCellIdentifier= @"NormalCell";
    ButtonCell *buttonCell= [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if(buttonCell== nil) { buttonCell= [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier]; }
    buttonCell.label.text= @"SUBMIT";
    return buttonCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row== 2) { [tokenCell showTextFieldKeyboard]; }
    if(indexPath.row== 3) {
        if([tokenCell.textField.text isEqualToString:@""]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:@"PLEASE CHECK. SOME FIELDS ARE EMPTY"]; return; }
        Profile *profile= [[self appDelegate].database fetchProfile];
        NSString *dingdong= profile.nearby;
        NSString *token= tokenCell.textField.text;
        tokenCell.textField.text= @"";
        [[self appDelegate].cloudilly linkGroup:[NSString stringWithFormat:@"dingdong:%@", dingdong] WithPassword:token WithCallback:^(NSDictionary *dict) {
            if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
            NSLog(@"@@@@@@ LINK");
            NSLog(@"%@", dict);
            
            NSMutableDictionary *dictDingdong= [[NSMutableDictionary alloc] init];
            [dictDingdong setObject:dingdong forKey:@"dingdong"];
            [dictDingdong setObject:token forKey:@"token"];
            [[self appDelegate].database updateDingdong:dictDingdong];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePairView" object:nil];
            
            [[self appDelegate].cloudilly listenGroup:dingdong WithCallback:^(NSDictionary *dict) {
                if([[dict objectForKey:@"status"] isEqual: @"fail"]) { [[self appDelegate] alertTitle:@"ERROR" AndMessage:[NSString stringWithFormat:@"%@", dict]]; return; }
                NSLog(@"@@@@@@ LISTEN");
                NSLog(@"%@", dict);
            }];
        }];
    }
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePairView" object:nil];
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end