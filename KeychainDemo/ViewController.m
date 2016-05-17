//
//  ViewController.m
//  KeychainDemo
//
//  Created by xuhaoran on 16/5/17.
//  Copyright © 2016年 house365. All rights reserved.
//

#import "ViewController.h"
#import "SSKeychain.h"

static NSString *kKeychainService = @"com.xuhaoran.keychaindemo";
static NSString *kKeychainDeviceId    = @"KeychainDeviceId";

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.uuidLabel.text = [NSString stringWithFormat:@"设备号:\n%@", [self getDeviceId]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.accountTextField) {
        self.accountTextField.text = nil;
        self.passwordTextField.text = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self loginAction:nil];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.accountTextField) {
        // 提取本地密码
        NSString *localPassword = [SSKeychain passwordForService:kKeychainService account:textField.text];
        if (localPassword) {
            self.passwordTextField.text = localPassword;
        }
    }
}

#pragma mark - responce action
- (IBAction)loginAction:(id)sender {
    if (!self.accountTextField.text || !self.passwordTextField.text) {
        [self showMsg:@"输入账号和密码!"];
        return;
    }
    [self showMsg:[NSString stringWithFormat:@"账户名:%@\n密码:%@", self.accountTextField.text, self.passwordTextField.text]];
    // 保存账号密码
    [SSKeychain setPassword:self.passwordTextField.text forService:kKeychainService account:self.accountTextField.text];
}

- (IBAction)clearAction:(id)sender {
    if (!self.accountTextField.text) {
        return;
    }
    if ([SSKeychain deletePasswordForService:kKeychainService account:self.accountTextField.text]) {
        [self showMsg:[NSString stringWithFormat:@"账户%@的密码已清空!", self.accountTextField.text]];
        self.passwordTextField.text = nil;
    }
    else {
        [self showMsg:@"删除失败了"];
    }
}

- (IBAction)searchAllAction:(id)sender {
    NSArray *accounts = [SSKeychain accountsForService:kKeychainService];
    NSLog(@"accounts:\n%@", accounts);
    [self showMsg:@"看下输出台"];
}

#pragma mark - private method
- (NSString *)getDeviceId {
    // 读取设备号
    NSString *localUUID = [SSKeychain passwordForService:kKeychainService account:kKeychainDeviceId];
    if (!localUUID) {
        // 保存设备号
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        assert(uuid != NULL);
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        [SSKeychain setPassword:[NSString stringWithFormat:@"%@", uuidStr] forService:kKeychainService account:kKeychainDeviceId];
        localUUID = [NSString stringWithFormat:@"%@", uuidStr];
    }
    return localUUID;
}

- (void)showMsg:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tip" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self showViewController:alert sender:nil];
}

@end
