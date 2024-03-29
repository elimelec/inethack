//
//  TouchInfoStore.h
//  iNetHack
//
//  Created by dirk on 8/6/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
//

//  This file is part of iNetHack.
//
//  iNetHack is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 2 of the License only.
//
//  iNetHack is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with iNetHack.  If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>

@class TouchInfo;

@interface TouchInfoStore : NSObject {
	
	NSMutableDictionary *currentTouchInfos;
	NSTimeInterval singleTapTimestamp;

}

@property (nonatomic, readonly) int count;
@property (nonatomic, assign) NSTimeInterval singleTapTimestamp;

- (void) storeTouches:(NSSet *)touches;
- (TouchInfo *) touchInfoForTouch:(UITouch *)t;
- (void) removeTouches:(NSSet *)touches;

@end
