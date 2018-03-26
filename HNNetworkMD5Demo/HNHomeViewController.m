//
//  HNHomeViewController.m
//  HNNetworkMD5Demo
//
//  Created by 孔焕宁 on 2018/3/25.
//  Copyright © 2018年 深圳市漫萌餐饮管理有限公司_孔焕宁_13411855114. All rights reserved.
//

#import "HNHomeViewController.h"
#import "HNHomeCell.h"
#import <CommonCrypto/CommonDigest.h>

@interface HNHomeViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    __weak IBOutlet UITableView *_tableView; // 表单
    __weak IBOutlet UITextField *_key; // key值
    __weak IBOutlet UITextField *_value; // value值
    __weak IBOutlet UITextField *_secretKey; // 密匙
    __weak IBOutlet UIButton *_addKeyValueBtn; // 增加keyValue按钮
    __weak IBOutlet UIButton *_doneBtn; // done按钮
}
@property (nonatomic, strong) UIColor *tempColor; // 临时保存的颜色
@property (nonatomic, strong) UITextField *tempTextField; // 临时输入框，又做键盘升起用
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*dataArr; // 数据池
@property (nonatomic, assign) BOOL first;; // 首次进入该界面
@property (nonatomic, strong) NSDictionary *dictionary; // 保存的密匙
@end

@implementation HNHomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MD5";
    self.first = YES;
    // 设置导航栏
    [self setupNaivgation];
    // 设置初始状态
    [self textFieldDidChange:nil];
    // 增加key、value、secretKey的监测事件，完成不同按钮间的状态切换
    [_key addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_value addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_secretKey addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // table初始化
    _tableView.tableFooterView = [UIView new];
    _tableView.tableHeaderView = [UIView new];
    _tableView.rowHeight = 44;
    [_tableView registerNib:[UINib nibWithNibName:[HNHomeCell description] bundle:nil] forCellReuseIdentifier:@"cell"];
    // 注册keyboard通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil]; //显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil]; // 隐藏
}

#pragma mark - func
// 导航栏设置
- (void)setupNaivgation {
    // 增加帮助选项
    UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithTitle:@"帮助" style:(UIBarButtonItemStyleDone) target:self action:@selector(helpAction:)];
    // 增加清空选项
    UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:(UIBarButtonItemStyleDone) target:self action:@selector(cleanAction:)];
    // 增加生成选项
    UIBarButtonItem *sureItem = [[UIBarButtonItem alloc] initWithTitle:@"生成" style:(UIBarButtonItemStyleDone) target:self action:@selector(creatAction:)];
    // 不得点击
    sureItem.enabled = NO;
    self.navigationItem.leftBarButtonItems = @[helpItem, cleanItem];
    self.navigationItem.rightBarButtonItem = sureItem;
}

// 监测输入框
- (void)textFieldDidChange:(UITextField *)textField {
    // 初始状态，密匙关闭，必须有一个keyValue值
    if (_key.text.length == 0 && _value.text.length == 0 && _secretKey.text.length == 0 && self.first) {
        _secretKey.enabled = [self handleEnabledWithBtn:_doneBtn enabled:NO];
        // 标记已浏览了
        self.first = NO;
        return;
    }
    // 必须增加一个密匙做结尾，所以当key或value有值时关闭done与secretKey的控制
    _secretKey.enabled = [self handleEnabledWithBtn:_doneBtn enabled:_key.text.length > 0 || _value.text.length > 0 ? NO:YES];
    // 如果输入了密匙，就认为是最后的数据，关闭key、value、addKeyValueBtn的控制
    _key.enabled = _value.enabled = [self handleEnabledWithBtn:_addKeyValueBtn enabled:_secretKey.text.length > 0 ? NO:YES];
}

// 设置按钮不可用时的状态及颜色,返回该按钮的状态
- (BOOL)handleEnabledWithBtn:(UIButton *)sender enabled:(BOOL)enabled {
    sender.enabled = enabled;
    sender.backgroundColor = enabled ? self.tempColor : [UIColor lightGrayColor];
    return enabled;
}

// 传入一个原始字典，依据ascii码从小到大排序，回传一个排好序的待签名字符串
- (NSString *)sortArrWithDictionary:(NSDictionary *)dictionary {
    // 取出所有的key值
    NSArray *keys = [dictionary allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    // 将排好的序的key值重新赋值
    NSMutableArray *jsonArr = [NSMutableArray array];
    [sortedArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 取出每一个keyValue值
        NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"", obj, dictionary[obj]];
        [jsonArr addObject:str];
    }];
    // 将做好排序的数组转出字符串
    NSString *result = [jsonArr componentsJoinedByString:@","];
    result = [NSString stringWithFormat:@"{%@}", result];
    return result;
}

- (NSString *)md5WithStr:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - action
// 点击了增加keyValue
- (IBAction)addKeyValueAction:(UIButton *)sender {
    // 监测杜绝数据的异常
    if (_key.text.length == 0 || _value.text.length == 0) {
        return;
    }
    // 将keyValue放进数据池
    [self.dataArr addObject:@{_key.text:_value.text}];
    // 更新输入输
    _key.text = _value.text = @"";
    // 更新表单
    [_tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    // 更新输入框逻辑
    [self textFieldDidChange:nil];
}

// 点击done
- (IBAction)doneAction:(UIButton *)sender {
    // 监测杜绝数据异常
    if (_secretKey.text.length == 0) {
        return;
    }
    // 将密匙放进数据池
    [self.dataArr addObject:@{@"key":_secretKey.text}];
    // 更新输入输
    _secretKey.text = @"";
    // 更新表单
    [_tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    // 更新输入框逻辑,关闭按钮事件
    _secretKey.text = @"";
    _secretKey.enabled = [ self handleEnabledWithBtn:_doneBtn enabled:NO];
    _key.enabled = _value.enabled = [self handleEnabledWithBtn:_addKeyValueBtn enabled:NO];
    // 允许点击了
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

// 点击了帮助
- (void)helpAction:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"帮助" message:@"该功能是体验一般性接口访问的加密规则与游戏。规则:将所有的key值按照ASCII码进行排序，将排序的值转成key1=value1&key2=value2的字符串,接着将密匙key=密匙放在最后，即key2=value2&key=密匙格式，将拼接好的字符串进行MD5加密得出的值轩成sign=转换后的值，加入到未排序前的字典中提交网络，详情请体验" preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDestructive handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 清空内容
- (void)cleanAction:(UIBarButtonItem *)sender {
    [self.dataArr removeAllObjects];
    [_tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    // 设置按钮可点
    _secretKey.enabled = [ self handleEnabledWithBtn:_doneBtn enabled:NO];
    _key.enabled = _value.enabled = [self handleEnabledWithBtn:_addKeyValueBtn enabled:YES];
    // 禁止生成
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

// 生成
- (void)creatAction:(UIBarButtonItem *)sender {
    // 将密匙独立保存出来
    self.dictionary = [self.dataArr lastObject];
    // 去除数组里的密匙
    NSMutableArray *tempArr = [self.dataArr mutableCopy];
    [tempArr removeLastObject];
    // 所有的字典合成一个
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [tempArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [obj.allKeys firstObject];
        NSString *value = [obj.allValues firstObject];
        [dictionary setValue:value forKey:key];
    }];
    // 处理好的数组开始排序并生成顺序的json
    NSString *jsonStr = [self sortArrWithDictionary:[dictionary copy]];
    // 打印
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"jsonStr" message:[NSString stringWithFormat:@"JSON字符串为%@私匙为%@，点击生成将私匙拼接进jsonStr", jsonStr, [self.dictionary.allValues firstObject]] preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 拼接好的字符串
        NSString *md5Str = [NSString stringWithFormat:@"%@%@", jsonStr, self.dictionary.allValues.firstObject];
        // 最后转成的MD5数值
        NSString *result = [self md5WithStr:md5Str];
        UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"MD5" message:[NSString stringWithFormat:@"MD5加密的字符串%@加密后的值为%@", md5Str, result] preferredStyle:(UIAlertControllerStyleAlert)];
        [alert2 addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [dictionary setValue:result forKey:@"key"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            NSString *resultJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            UIAlertController *alert3 = [UIAlertController alertControllerWithTitle:@"最终需要进行网络请求的json" message:resultJson preferredStyle:(UIAlertControllerStyleAlert)];
            [alert3 addAction:[UIAlertAction actionWithTitle:@"谢谢" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // 无
            }]];
            [self presentViewController:alert3 animated:YES completion:nil];
        }]];
        [self presentViewController:alert2 animated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.tempTextField = textField;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _key) {
        [_value becomeFirstResponder]; // 下一步
    } else if (textField == _value) {
        [self.view endEditing:YES]; // 完成
    } else if (textField == _secretKey) {
        [self.view endEditing:YES]; // 完成
    }
    return YES;
}

#pragma mark - keyboardNotification
// 键盘显示
- (void)keyboardShow:(NSNotification *)notification {
    // 获取通知信息
    NSDictionary *dictionary = notification.userInfo;
    // 得到frame的对象
    NSValue *value = [dictionary valueForKey:UIKeyboardFrameEndUserInfoKey];
    // 强转
    CGRect keyboardRect = value.CGRectValue;
    // 加距
    CGFloat padding = 20;
    // 计算是否需要移动窗口
    CGFloat height = [UIScreen mainScreen].bounds.size.height - self.tempTextField.frame.size.height - self.tempTextField.frame.origin.y;
    if (height < keyboardRect.size.height + padding) {
        // 动画升起
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = - (keyboardRect.size.height - height + padding);
            self.view.frame = frame;
        }];
    }
}

// 键盘隐藏
- (void)keyboardHidden:(NSNotification *)notification {
    // 动画结束
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dictionary = self.dataArr[indexPath.row];
    cell.dictionary = dictionary;
    return cell;
}
#pragma mark - get
- (UIColor *)tempColor {
    if (!_tempColor) {
        _tempColor = _addKeyValueBtn.backgroundColor;
    }
    return _tempColor;
}

- (NSMutableArray<NSDictionary *> *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
@end
