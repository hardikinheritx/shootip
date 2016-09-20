//
//  SearchDetailsVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/18/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "SearchDetailsVC.h"
#import "CommentVC.h"
@interface SearchDetailsVC ()

@end

@implementation SearchDetailsVC

@synthesize isAlbumSelect;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblTitleName.text = self.strTitleName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (isAlbumSelect) {
        
         return 356;
    }
    
    else {
        
         return 393;
    }
   
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (isAlbumSelect)  {
        
        static NSString *cellID =  @"AlbumCell";
        
        AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"AlbumCell" bundle:nil] forCellReuseIdentifier:cellID];
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        }

        
        cell.lblAlbumName.text = self.strTitleName;
        
        cell.lblAlbumDuration.text = @"2:15";
        
        [cell.btnAlbumName addTarget:self action:@selector(actionAlbumname:) forControlEvents:UIControlEventTouchUpInside];
        
        
#pragma mark -  Make User Profile Image Rounded
        cell.imgPostUser.layer.cornerRadius = cell.imgPostUser.frame.size.width / 2;
        cell.imgPostUser.layer.borderWidth = 1.0f;
        cell.imgPostUser.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imgPostUser.clipsToBounds = YES;
        
        
        return cell;

    }
    
    else {
    
        static NSString *cellID =  @"VideoPostCell";
        
        VideoPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"VideoPostCell" bundle:nil] forCellReuseIdentifier:cellID];
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        }
        [cell.btnComment addTarget:self action:@selector(btnCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        
//            [cell ConfigureCell];
        return cell;

    }
    
}
-(void)btnCommentAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"CommentSegue" sender:nil];
}


#pragma mark - Action for UnWatch Button
-(void)actionAlbumname:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblSearch];
    NSIndexPath *indexPath = [tblSearch indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        AlbumDetailsVC *albumdetailsvc = (AlbumDetailsVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumDetailsVC"];
        [self.navigationController pushViewController:albumdetailsvc animated:YES];
    }
}

#pragma mark - Action for back Button
- (IBAction)actionback:(id)sender {
    
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
