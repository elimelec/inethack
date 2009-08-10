//
//  Shortcut.m
//  iNetHack
//
//  Created by dirk on 7/14/09.
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

#import "Shortcut.h"
#import "MainViewController.h"
#import "NethackEventQueue.h"

@implementation Shortcut

@synthesize title;

- (id) initWithTitle:(NSString *)t keys:(NSString *)k selector:(SEL)s target:(id)tar arg:(id)a {
	if (self = [super init]) {
		title = [t retain];
		keys = [k retain];
		selector = s;
		target = [tar retain];
		arg = [a retain];
	}
	return self;
}

- (id) initWithTitle:(NSString *)t keys:(NSString *)k {
	return [self initWithTitle:t keys:k selector:NULL target:nil arg:nil];
}

- (id) initWithTitle:(NSString *)t key:(int)k {
	char s[] = { k, 0 };
	NSString *string = [[NSString alloc] initWithCString:s];
	self = [self initWithTitle:t keys:string selector:NULL target:nil arg:nil];
	[string release];
	return self;
}

- (char) key {
	return [keys characterAtIndex:0];
}

- (void) invoke {
	if (target) {
		[target performSelector:selector withObject:arg];
	} else {
		NethackEventQueue *q = [[MainViewController instance] nethackEventQueue];
		for (int i = 0; i < keys.length; ++i) {
			[q addKeyEvent:[keys characterAtIndex:i]];
		}
	}
}

- (void) dealloc {
	[title release];
	[keys release];
	[target release];
	[arg release];
	[super dealloc];
}

@end