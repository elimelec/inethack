//
//  Window.h
//  iNetHack
//
//  Created by dirk on 6/26/09.
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

#include "hack.h"

#define kNoGlyph (-1)

@class NethackMenuItem;

@interface Window : NSObject <NSLocking> {
	
	int type;
	int curx;
	int cury;
	int width;
	int height;
	
	int maxWidth;
	int maxHeight;
	
	int *glyphs;
	NSMutableArray *strings;
	int maxLogEntries;
	NSMutableArray *log;
	
	NSMutableArray *menuItems;
	NSString *menuPrompt;
	BOOL isShallowMenu;
	int menuHow;
	menu_item *menuList;
	int menuResult;

	NSString *prompt;
	BOOL acceptBareHanded;
	BOOL acceptMore;
	BOOL acceptMoney;
	
	// used for determining amounts on PICK_ONE
	NethackMenuItem *nethackMenuItem;
	
	NSCondition *messageCondition;
	
	// used when there are too many messages to fit on screen
	BOOL shouldDisplay;
	
	// used for blocking map display (e.g. spell of detect monsters)
	BOOL blocking;
}

@property (nonatomic, readonly) int type;
@property (nonatomic, assign) int curx;
@property (nonatomic, assign) int cury;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, readonly) NSMutableArray *strings;
@property (nonatomic, readonly) NSMutableArray *log;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSMutableArray *menuItems;
@property (nonatomic, retain) NSString *menuPrompt;
@property (nonatomic, readonly) BOOL isShallowMenu;
@property (nonatomic, assign) int menuHow;
@property (nonatomic, assign) menu_item *menuList;
@property (nonatomic, assign) int menuResult;
@property (nonatomic, retain) NethackMenuItem *nethackMenuItem;

@property (nonatomic, assign) BOOL acceptBareHanded;
@property (nonatomic, assign) BOOL acceptMore;
@property (nonatomic, assign) BOOL acceptMoney;

@property (assign) BOOL shouldDisplay;
@property (assign) BOOL blocking;

- (id) initWithType:(int)t;
- (int) glyphAtX:(int)x y:(int)y;
- (void) setGlyph:(int)g atX:(int)x y:(int)y;
- (void) clear;
- (void) putString:(const char *)s;
- (void) startMenu;
- (void) addMenuItem:(NethackMenuItem *)item;
- (void) addLogString:(NSString *)s;
- (void) clearMessages;

@end
