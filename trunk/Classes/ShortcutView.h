//
//  ShortcutView.h
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

#import <UIKit/UIKit.h>

@class ShortcutViewController, TouchInfoStore;

@interface ShortcutView : UIView {
	
	UIFont *font;
	NSArray *shortcuts;
	NSUInteger currentIndex;
	int maxShortcutsOnScreen;
	CGSize tileSize;
	int recentlyTouchedItem;
	TouchInfoStore *touchInfoStore;
	
}
@property (nonatomic, retain) NSArray* shortcuts;
@end
