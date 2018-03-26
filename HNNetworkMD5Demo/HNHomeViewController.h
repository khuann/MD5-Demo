//
//  HNHomeViewController.h
//  HNNetworkMD5Demo
//
//  Created by 孔焕宁 on 2018/3/25.
//  Copyright © 2018年 深圳市漫萌餐饮管理有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  该功能是体验一般性接口访问的加密规则与游戏。规则:将所有的key值按照ASCII码进行排序，将排序的值转成key1=value1&key2=value2的字符串,接着将密匙key=密匙放在最后，即key2=value2&key=密匙格式，将拼接好的字符串进行MD5加密得出的值轩成sign=转换后的值，加入到未排序前的字典中提交网络，详情请体验
 */
@interface HNHomeViewController : UIViewController

@end
