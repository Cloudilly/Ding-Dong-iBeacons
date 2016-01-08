//
//  BeaconViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 21/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "BeaconViewController.h"

@interface BeaconViewController()
@end

@implementation BeaconViewController

-(id)init {
    self= [super init];
    if(self) {
        dingdongFetchedResultsController= [self dingdongFetchedResultsController];
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
    title.text= @"Associations";
    [self.view addSubview:title];
    
    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    beaconTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    beaconTableView.backgroundColor= [UIColor whiteColor];
    beaconTableView.delegate= self;
    beaconTableView.dataSource= self;
    beaconTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:beaconTableView];
}

-(NSFetchedResultsController *)dingdongFetchedResultsController {
    NSManagedObjectContext *context= [[self appDelegate].database managedObjectContext];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Dingdong" inManagedObjectContext:context];
    NSSortDescriptor *sort= [[NSSortDescriptor alloc] initWithKey:@"dingdong" ascending:YES];
    NSArray *sortDescriptors= [NSArray arrayWithObjects:sort, nil]; NSFetchRequest *request= [[NSFetchRequest alloc] init];
    request.entity= entity; request.sortDescriptors= sortDescriptors;
    dingdongFetchedResultsController= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    dingdongFetchedResultsController.delegate= self; [dingdongFetchedResultsController performFetch:nil];
    return dingdongFetchedResultsController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [beaconTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSArray *dingdongs= [[self appDelegate].database fetchDingdongs];
    return dingdongs.count+ 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row== 0) {
        static NSString *TitleCellIdentifier= @"TitleCell";
        TitleCell *titleCell= [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if(titleCell== nil) { titleCell= [[TitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier]; }
        NSArray *dingdongs= [[self appDelegate].database fetchDingdongs];
        titleCell.label.text= dingdongs.count== 0 ? @"Not yet paired with any DingDong" : @"Paired DingDongs";
        return titleCell;
    }
    
    static NSString *NormalCellIdentifier= @"NormalCell";
    NormalCell *normalCell= [tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
    if(normalCell== nil) { normalCell= [[NormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier]; }
    Dingdong *dingdong= [dingdongFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row- 1];
    normalCell.label.text= dingdong.dingdong;
    normalCell.value.text= [NSString stringWithFormat:@"%@", dingdong.devices];
    return normalCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row== 0) { return; }
    Dingdong *dingdong= [dingdongFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row- 1];
    NSMutableDictionary *dictUserInfo= [[NSMutableDictionary alloc] init];
    [dictUserInfo setObject:dingdong.dingdong forKey:@"recipient"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessageView" object:nil userInfo:dictUserInfo];
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideBeaconView" object:nil];
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end