//
//  NSData+CRC32.h
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface NSData (CRC32)

-(int32_t)crc_32;

-(uLong)getCRC32;

@end

