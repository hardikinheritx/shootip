//
//  AlbumDetailsVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/19/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "AlbumDetailsVC.h"
#import "VideoPostCell.h"
#import "CommentVC.h"
@interface AlbumDetailsVC ()

@end

@implementation AlbumDetailsVC

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Album Detail Screen"];
    [APPDELEGATE setDropOffScreen:@"Album Detail Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 393;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =  @"VideoPostCell";
    
    VideoPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"VideoPostCell" bundle:nil] forCellReuseIdentifier:cellID];
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    [cell.btnComment addTarget:self action:@selector(btnCommentAction:) forControlEvents:UIControlEventTouchUpInside];

//        [cell ConfigureCell];
    return cell;
}
-(void)btnCommentAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"CommentSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action for back Button
- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   if ([segue.identifier isEqualToString:@"CommentSegue"])
    {
        CommentVC *objComment = segue.destinationViewController;
        objComment.isForPost=YES;
    }
}
@end
