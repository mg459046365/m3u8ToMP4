//
//  TS2MP4.h
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/16.
//  Copyright © 2019 Beryter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TS2MP4 : NSObject
+ (NSError *)convertTS:(NSString *)tsPath toMP4:(NSString *)mp4Path;
@end
