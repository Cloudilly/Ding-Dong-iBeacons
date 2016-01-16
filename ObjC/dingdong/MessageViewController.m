//
//  MessageViewController.m
//  dingdong
//
//  Created by Zhongcai Ng on 22/11/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController()
@end

@implementation MessageViewController

-(id)initWithRecipient:(NSString *)_recipient {
    self= [super init];
    if(self) {
        recipient= _recipient;
        messageFetchedResultsController= [self messageFetchedResultsController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
    title.text= recipient;
    [self.view addSubview:title];
    
    UIButton *backBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(fireBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame= CGRectMake(0.0, 20.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    messageTableView= [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, width, height- 120.0) style:UITableViewStylePlain];
    messageTableView.backgroundColor= [UIColor whiteColor];
    messageTableView.delegate= self;
    messageTableView.dataSource= self;
    messageTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [self.view addSubview:messageTableView];
    
    bottom= [[UIView alloc] initWithFrame:CGRectMake(0.0, height- 50.0, width, 50.0)];
    bottom.userInteractionEnabled= YES;
    bottom.backgroundColor= [UIColor grayColor];
    [self.view addSubview:bottom];
    
    UIView *text= [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, width- 70.0, 40.0)];
    text.backgroundColor= [UIColor whiteColor];
    [bottom addSubview:text];
    
    field= [[UITextField alloc] initWithFrame:CGRectMake(10.0, 0.0, width- 80.0, 40.0)];
    field.keyboardAppearance= UIKeyboardAppearanceDark;
    field.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
    field.autocorrectionType= UITextAutocorrectionTypeYes;
    field.font= [UIFont systemFontOfSize:22.0];
    field.returnKeyType= UIReturnKeySend;
    field.delegate= self;
    [text addSubview:field];
    
    UIButton *sendBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn addTarget:self action:@selector(fireSend) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font= [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:22.0];
    sendBtn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
    sendBtn.frame= CGRectMake(width- 60.0, 0.0, 60.0, 50.0);
    [bottom addSubview:sendBtn];
    [self.view addSubview:bottom];
}

-(NSFetchedResultsController *)messageFetchedResultsController {
    NSManagedObjectContext *context= [[self appDelegate].database managedObjectContext];
    NSEntityDescription *entity= [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"recipient== %@", recipient];
    NSSortDescriptor *sort= [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors= [NSArray arrayWithObjects:sort, nil]; NSFetchRequest *request= [[NSFetchRequest alloc] init];
    request.entity= entity; request.predicate= predicate; request.sortDescriptors= sortDescriptors;
    messageFetchedResultsController= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    messageFetchedResultsController.delegate= self; [messageFetchedResultsController performFetch:nil];
    return messageFetchedResultsController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [messageTableView reloadData];
    [self scrollToBottom];
}

-(void)fireBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideMessageView" object:nil];
}

-(void)fireSend {
    if(field.text.length== 0) { return; }
    NSMutableDictionary *payload= [[NSMutableDictionary alloc] init];
    [payload setObject:field.text forKey:@"message"];
    [[self appDelegate].cloudilly postGroup:recipient WithPayload:payload WithCallback:^(NSDictionary *dict) {
        if([[dict objectForKey:@"status"] isEqual: @"fail"]) { NSLog(@"ERROR %@", dict); return; }
        NSLog(@"@@@@@@ POST");
        NSLog(@"%@", dict);
    }];
    field.text= @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(field.text.length== 0) { return NO; }
    NSMutableDictionary *payload= [[NSMutableDictionary alloc] init];
    [payload setObject:field.text forKey:@"message"];
    [[self appDelegate].cloudilly postGroup:recipient WithPayload:payload WithCallback:^(NSDictionary *dict) {
        if([[dict objectForKey:@"status"] isEqual: @"fail"]) { NSLog(@"ERROR %@", dict); return; }
        NSLog(@"@@@@@@ POST");
        NSLog(@"%@", dict);
    }];
    field.text= @"";
    return NO;
}

-(CGFloat)returnMessageHeight:(NSString *)message {
    NSDictionary *attributeNormal= [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:18.0] forKey:NSFontAttributeName];
    return [message boundingRectWithSize:CGSizeMake(width- 20.0, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeNormal context:nil].size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message= [messageFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    return [self returnMessageHeight:message.message]+ 20.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return messageFetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MessageCellIdentifier= @"MessageCell";
    UITableViewCell *messageCell= [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
    if(messageCell== nil) { messageCell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier]; }
    Message *message= [messageFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    messageCell.textLabel.text= [NSString stringWithFormat:@"%@: %@", message.sender, message.message];
    messageCell.textLabel.numberOfLines= 0;
    return messageCell;
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame= [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float keyboardHeight= height- keyboardFrame.origin.y;
    double duration= [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        messageTableView.frame= CGRectMake(0.0, 70.0, width, height- 70.0- 49.0- keyboardHeight);
        bottom.frame= CGRectMake(0.0, height- 50.0- keyboardHeight, width, 50.0);
        [self scrollToBottom];
    }];
}

-(void)scrollToBottom {
    if(messageTableView.contentSize.height< messageTableView.frame.size.height) { return; }
    double delayInSeconds= 0.1; dispatch_time_t popTime= dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        CGPoint offset= CGPointMake(0, messageTableView.contentSize.height- messageTableView.frame.size.height);
        [messageTableView setContentOffset:offset animated:YES];
    });
}

-(AppDelegate *)appDelegate { return (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(void)viewDidLoad { [super viewDidLoad]; }
-(void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end