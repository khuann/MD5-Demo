//
//  HNHomeCell.m
//  HNNetworkMD5Demo
//
//  Created by 孔焕宁 on 2018/3/25.
//  Copyright © 2018年 深圳市漫萌餐饮管理有限公司. All rights reserved.
//

#import "HNHomeCell.h"

@implementation HNHomeCell {
    __weak IBOutlet UILabel *_key;
    __weak IBOutlet UILabel *_value;
}

- (void)setDictionary:(NSDictionary *)dictionary {
    _dictionary = dictionary;
    _key.text = [dictionary.allKeys firstObject];
    _value.text = [dictionary.allValues firstObject];
}

@end
