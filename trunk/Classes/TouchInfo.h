//
//  TouchInfo.h
//  iNetHack
//
//  Created by dirk on 8/6/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchInfo : NSObject {
	
	BOOL pinched;
	BOOL moved;
	CGPoint initialLocation;

}

@property (nonatomic, assign) BOOL pinched;
@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) CGPoint initialLocation;

- (id) initWithTouch:(UITouch *)t;

@end
