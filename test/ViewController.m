//
//  ViewController.m
//  test
//
//  Created by jiali xiao on 2022/5/29.
//

#import "ViewController.h"
#import "VungleManager.h"

#define BANNER_AD_HEIGHT 50.0
#define BANNER_SHORT_AD_WIDTH 300.0
#define BANNER_AD_WIDTH 320.0
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height - 80
#define SCREEN_WIDTH self.view.frame.size.width
#define MREC_AD_HEIGHT 250.0
#define MREC_AD_WIDTH 300

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, strong) NSArray* listData;
@property(nonatomic, strong) UIView *bannerView;
@property(nonatomic, strong) UIView *MRECView;
@property(nonatomic, strong) NSString *headerTitle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // table view data is being set here
    self.listData = [[NSArray alloc] initWithObjects:
    @"Interstitial Ads",@"Rewarded Ads",@"Banner Ads",
    @"MREC Ads", nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- BANNER_AD_HEIGHT))];
    self.tableView.rowHeight = 80;
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.sectionFooterHeight = 44;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.bannerView = [[UIView alloc] initWithFrame: (CGRectMake((SCREEN_WIDTH - BANNER_SHORT_AD_WIDTH)/2, SCREEN_HEIGHT- BANNER_AD_HEIGHT, BANNER_SHORT_AD_WIDTH, BANNER_AD_HEIGHT))];
    self.MRECView = [[UIView alloc] initWithFrame: (CGRectMake((SCREEN_WIDTH - MREC_AD_WIDTH)/2, SCREEN_HEIGHT- MREC_AD_HEIGHT, MREC_AD_WIDTH, MREC_AD_HEIGHT))];
    
    [self.view addSubview:self.tableView ];
    [self.view addSubview:self.bannerView];
    [self.view addSubview:self.MRECView];
    self.bannerView.hidden = YES;
    self.MRECView.hidden = YES;
    
    self.headerTitle = @"SDK Uninitialized!";
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [[VungleManager instanceShared] startVungleWithCompletionHandler:^(bool status) {
            if(status)
                self.headerTitle = @"SDK initialized!";
            else
                self.headerTitle = @"SDK init Failed!";
            [self.tableView reloadData];
        }];
    });

}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
  (NSInteger)section{
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
  (NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if(indexPath.row>=0 && indexPath.row < [self.listData count]){
        [cell.textLabel setText:self.listData[indexPath.row]];

    }
 
   
    return cell;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
  (NSInteger)section{
    
    return self.headerTitle;
}



#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
 (NSIndexPath *)indexPath{
    if(![[VungleManager instanceShared] isInitialized]){
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"SDK is not intialized" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[VungleManager instanceShared] finishDisplayingAd];
    self.MRECView.hidden = YES;
    self.bannerView.hidden = YES;
    switch(indexPath.row){
        case 0:
        case 1:
        {
            [[VungleManager instanceShared] startLoadAds:(VungleAdsType)(indexPath.row) forViewC:self orView:nil];
            break;
        }
        case 2:
        {
            self.bannerView.hidden = NO;
            [[VungleManager instanceShared] startLoadAds:(VungleAdsType)(indexPath.row) forViewC:self orView:self.bannerView];
            break;
        }
        case 3:
        {
            self.MRECView.hidden = NO;
            [[VungleManager instanceShared] startLoadAds:(VungleAdsType)(indexPath.row) forViewC:self orView:self.MRECView];
            break;
        }
    }
    
}



@end
