//
//  CommentVC.m
//  ShootIP
//
//  Created by milap kundalia on 1/21/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "CommentVC.h"
#import "CommentCell.h"
@interface CommentVC () <UITextViewDelegate>
{
    BOOL isKeyboardOpen;
    NSArray *arrComments;
    UILabel *messageLabel ;
}
@end

@implementation CommentVC
@synthesize strPostId;
#pragma mark - View life cycle methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tblComments.rowHeight = UITableViewAutomaticDimension;
    viewComment.minNumberOfLines = 1;
    viewComment.maxNumberOfLines = 3;
    viewComment.delegate = self;
    viewComment.layer.borderWidth = 1.1;
    viewComment.layer.borderColor = [UIColor colorWithRed:0.337 green:0.659 blue:0.467 alpha:1.000].CGColor;
    viewComment.font =[UIFont fontWithName:@"MyriadPro-Regular" size:14.0f];

    viewComment.placeholder = @"Type a comment";
    // Do any additional setup after loading the view.
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    [self addObserver];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGesture:)];
    tapGesture.numberOfTapsRequired = 1.0;
    [tblComments addGestureRecognizer:tapGesture];
    
    [self getAllCommentsWebServiceCall];
    
    messageLabel  = [[UILabel alloc] init];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self removeObserver];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollTableToBottam];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Comment Screen"];
    [APPDELEGATE setDropOffScreen:@"Comment Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}
#pragma mark - Web call -

-(void)addCommentWebServiceCall
{
    NSMutableDictionary * dictAddCommentParams=[[NSMutableDictionary alloc] init];
    [dictAddCommentParams setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictAddCommentParams setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    
    [dictAddCommentParams setObject:viewComment.text forKey:KEYCOMMENTTEXT];

    [SVProgressHUD show];
    if (_isForPost==YES) {
        [dictAddCommentParams setObject:strPostId forKey:KEYPOSTID];

        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIADDCOMMENT_POST method:@"POST" data:dictAddCommentParams withImages:nil withVideo:nil];
        
    }
    else{
        [dictAddCommentParams setObject:strPostId forKey:KEYALBUMID];

        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIADDCOMMENT_ALBUM method:@"POST" data:dictAddCommentParams withImages:nil withVideo:nil];
        
    }
}
-(void)getAllCommentsWebServiceCall
{
    NSMutableDictionary * dictAllCommentsParams=[[NSMutableDictionary alloc] init];
    [dictAllCommentsParams setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictAllCommentsParams setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];


    
    [SVProgressHUD show];
    
    if (_isForPost==YES) {
        [dictAllCommentsParams setObject:strPostId forKey:KEYPOSTID];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIGETALLCOMMENT_POST method:@"POST" data:dictAllCommentsParams withImages:nil withVideo:nil];

    }
    else{
        [dictAllCommentsParams setObject:strPostId forKey:KEYALBUMID];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIGETALLCOMMENT_ALBUM method:@"POST" data:dictAllCommentsParams withImages:nil withVideo:nil];

    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - HPGrowingTextView Delegate -
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
   growingTextView.internalTextView.attributedText=[self decorateTags:growingTextView.text];
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = viewComment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    viewComment.frame = r;
    [viewCommentHeightConstraint setConstant:r.size.height];
}

-(void)scrollTableToBottam
{
    //    CGPoint scrollPoint = CGPointMake(0, _viewHPGrowintTextView.frame.origin.y);
    //    scrollPoint = [tblUserComment convertPoint:scrollPoint fromView:_viewHPGrowintTextView.superview];
    //    [tblUserComment setContentOffset:scrollPoint animated:YES];
    if ([arrComments count]>0)
    {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:[arrComments count] - 1  inSection:0];
        [tblComments scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
    }
    
}
#pragma mark - Keyboard Notification Methods -

- (void)keyboardDidShow:(NSNotification *)notification
{
    isKeyboardOpen = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    [contentViewBottomConstraint setConstant:height];
     [self scrollTableToBottam];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    isKeyboardOpen = NO;
    [contentViewBottomConstraint setConstant:0];
    [self scrollTableToBottam];
}

-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
-(void)TapGesture:(UIGestureRecognizer *)objGesture
{
    if (objGesture.state == UIGestureRecognizerStateEnded)
    {
        if (isKeyboardOpen)
            [self.view endEditing:YES];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Tableview methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    messageLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    // Return the number of sections.
    if (arrComments)
    {
        messageLabel.text=@"";
//        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    }
    else
    {
        // Display a message when the table is empty
        //        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No comments yet be the first to comment on this post.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrComments.count;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID =  @"CommentCell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.imgUserProfilePic.layer.cornerRadius = cell.imgUserProfilePic.frame.size.width / 2;
    cell.imgUserProfilePic.clipsToBounds = YES;
    cell.imgUserProfilePic.layer.borderWidth = 1.5f;
    cell.imgUserProfilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    NSDictionary *dictComment=[arrComments objectAtIndex:indexPath.row];
    
    cell.lblComment.attributedText=[self decorateTags:[dictComment objectForKey:@"comment_text"]];
    
    NSURLRequest *userProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[dictComment objectForKey:@"user_data"] objectForKey:@"user_image"]]];
    UIImage *placeholderImage = [UIImage imageNamed:@"user_placeholder_icon"];

    [cell.imgUserProfilePic setImageWithURLRequest:userProfileRequest
                           placeholderImage:placeholderImage
                                    success:nil
                                    failure:nil];

    
//    {
//        "album_id" = 9;
//        "comment_id" = 10;
//        "comment_text" = "dasjdhasd kdasjasd ;osdfs;dfs dfsd;fsd fsdfsdfm sdfk sp'd; fsdf .s/dkfsd f s.df ksdf . ";
//        "user_data" =     {
//            "user_id" = 22;
//            "user_image" = "http://inheritxdev.net/shootip/api/web/../../common/web/img/no_image.png";
//            "user_name" = milap;
//        };
//    }

    
    
    
    
    if (indexPath.row % 2 == 0) {
        cell.viewBG.backgroundColor=[UIColor colorWithRed:60.0/255.0f green:60.0/255.0f blue:60.0/255.0f alpha:1.0];
    }
    else{
        cell.viewBG.backgroundColor=[UIColor colorWithRed:40.0/255.0f green:40.0/255.0f blue:40.0/255.0f alpha:1.0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   // cell.textLabel.text = @"Hello";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Button action methods -
- (IBAction)btnBackAction:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:strPostId,KEYPOSTID,_strCommentCount,KEYTOTALCOMMENTS, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: UPDATECOMMENTCOUNTNOTIFICATION object:nil userInfo:userInfo];

//    [self performSegueWithIdentifier:@"UnwindFromComment" sender:nil];
    
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendCommentAction:(id)sender {
    
    NSString *trimmedString = [viewComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([trimmedString length]>0) {
       // [Alerts showAlertWithMessage:@"Comment added successfully." withBlock:nil andButtons:ALERT_OK, nil];
        
        [self addCommentWebServiceCall];

        viewComment.text=@"";
//        [viewComment resignFirstResponder];
    }
    else{
         viewComment.text=@"";
        [Alerts showAlertWithMessage:@"Please enter the comment." withBlock:nil andButtons:ALERT_OK, nil];
    }
    
}

-(NSMutableAttributedString*)decorateTags:(NSString *)stringWithTags{
    
    
    NSError *error = nil;
    
    //For "Vijay #Apple Dev"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    
    //For "Vijay @Apple Dev"
    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:stringWithTags options:0 range:NSMakeRange(0, stringWithTags.length)];
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:stringWithTags];
    
    NSInteger stringLength=[stringWithTags length];
    
    for (NSTextCheckingResult *match in matches) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        
        NSString* word = [stringWithTags substringWithRange:wordRange];
        
        //Set Font
        UIFont *font=[UIFont fontWithName:@"MyriadPro-Regular" size:14.0f];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, stringLength)];
        
        
        //Set Background Color
//        UIColor *backgroundColor=[UIColor orangeColor];
//        [attString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:wordRange];
        
        //Set Foreground Color //75,88,18
        UIColor *foregroundColor=[UIColor colorWithRed:0.267 green:0.937 blue:0.702 alpha:1.000];
        [attString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:wordRange];
        
        NSLog(@"Found tag %@", word);
        
    }
    
    // Set up your text field or label to show up the result
    
    //    yourTextField.attributedText = attString;
    //
    //    yourLabel.attributedText = attString;
    
    return attString;
}



- (void)formatTextInTextView:(HPGrowingTextView *)textView
{
    textView.internalTextView.scrollEnabled = NO;
    NSRange selectedRange = textView.selectedRange;
    NSString *text = textView.text;
    
    // This will give me an attributedString with the base text-style
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match rangeAtIndex:0];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor redColor]
                                 range:matchRange];
    }
    
    textView.internalTextView.attributedText = attributedString;
    textView.selectedRange = selectedRange;
    textView.internalTextView.scrollEnabled = YES;
}
#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
  //  NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APIGETALLCOMMENT_POST])
        {
            arrComments=[NSArray arrayWithArray:[dictData objectForKey:@"data"]];
            _strCommentCount = [NSString stringWithFormat:@"%lu",(unsigned long)[arrComments count]];
            [tblComments reloadData];
            [self scrollTableToBottam];

        }
        if ([reqURL myContainsString:APIGETALLCOMMENT_ALBUM])
        {
            arrComments=[NSArray arrayWithArray:[dictData objectForKey:@"data"]];
            [tblComments reloadData];
            [self scrollTableToBottam];


        }
        if ([reqURL myContainsString:APIADDCOMMENT_POST])
        {
            [self getAllCommentsWebServiceCall];


        }
        if ([reqURL myContainsString:APIADDCOMMENT_ALBUM])
        {
            [self getAllCommentsWebServiceCall];

            
        }
        [SVProgressHUD dismiss];
    }
    else
    {
//        [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}



@end
