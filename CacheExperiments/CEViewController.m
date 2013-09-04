//
//  CEViewController.m
//  CacheExperiments
//
//
//

#import "CEViewController.h"
#import <AFNetworking.h>

@interface CEViewController ()

@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UIButton *cacheUsageButton;
@property (weak, nonatomic) IBOutlet UITextView *headersTextView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *diskUsageLabel;

@end

@implementation CEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [self updateCacheInfo];
    
    [self clearTextViews];
}

- (void)clearTextViews {
    self.headersTextView.text = nil;
    self.responseTextView.text = nil;
}

- (void)updateCacheInfo {
    self.diskUsageLabel.text = [NSString stringWithFormat:@"Disk usage: %d\nMemory usage: %d",
                                [NSURLCache sharedURLCache].currentDiskUsage,
                                [NSURLCache sharedURLCache].currentMemoryUsage];
}

- (NSURLRequest *)buildRequest {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlTextField.text]];
    return request;
}

- (void)sendRequest {
    [self sendRequest:[self buildRequest]];
}

- (void)sendRequest:(NSURLRequest *)request {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.headersTextView.text = [operation.response.allHeaderFields description];
        self.responseTextView.text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self updateCacheInfo];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.headersTextView.text = [error localizedDescription];
    }];
    
    [operation start];
}

- (IBAction)sendRequestButtonTapped:(id)sender {
    [self.view resignFirstResponder];
    [self clearTextViews];
    [self sendRequest];
}

- (IBAction)obtainFromCacheButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self clearTextViews];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self buildRequest]];
    if (cachedResponse) {
        self.headersTextView.text = [((NSHTTPURLResponse *)cachedResponse.response).allHeaderFields description];
        self.responseTextView.text = [[NSString alloc] initWithData:cachedResponse.data encoding:NSUTF8StringEncoding];
    }
}

- (IBAction)clearCacheButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self updateCacheInfo];
}

- (IBAction)etagButtonTapped:(id)sender {
    [self.view endEditing:YES];
    self.urlTextField.text = @"http://127.0.0.1:8000/api/et";
}

- (IBAction)lastModifedButtonTapped:(id)sender {
    [self.view endEditing:YES];
    self.urlTextField.text = @"http://127.0.0.1:8000/api/lm";
}

- (IBAction)cacheControlButtonTapped:(id)sender {
    [self.view endEditing:YES];
    self.urlTextField.text = @"http://127.0.0.1:8000/api/cc";
}

@end
