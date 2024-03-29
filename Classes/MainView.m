//
//  MainView.m
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

#import "MainView.h"
#import "MainViewController.h"
#import "Window.h"
#import "TilePosition.h"
#import "TileSet.h"
#import "ShortcutView.h"
#import "Shortcut.h"
#import "AsciiTileSet.h"

#define kKeyTileset (@"tileset")

@implementation MainView

@synthesize start, tileSize, dummyTextField, tileSet;
@synthesize status, map, message;

+ (void) initialize {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:40] forKey:kKeyTileSize]];
	[pool drain];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	
	bundleVersionString = [[NSString alloc] initWithFormat:@"%@",
						   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	statusFont = [UIFont systemFontOfSize:16];
	
	// tileSize
	maxTileSize = tilesetTileSize = CGSizeMake(32,32);
	minTileSize = CGSizeMake(8,8);
	offset = CGPointMake(0,0);
	float ts = [[NSUserDefaults standardUserDefaults] floatForKey:kKeyTileSize];
	tileSize = CGSizeMake(ts,ts);
	if (tileSize.width > maxTileSize.width) {
		tileSize = maxTileSize;
	} else if (tileSize.width < minTileSize.width) {
		tileSize = minTileSize;
	}
	
	// load tileset
	NSString *tilesetName = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyTileset];
	if (!tilesetName) {
		tilesetName = @"chozo32b";
	}
	if ([tilesetName isEqualToString:@"ascii"]) {
		asciiTileset = YES;
		tileSet = [[AsciiTileSet alloc] initWithTileSize:tilesetTileSize];
	} else {
		if ([tilesetName isEqualToString:@"nhtiles"]) {
			tilesetTileSize = CGSizeMake(16,16);
			maxTileSize = tilesetTileSize;
			if (tileSize.width > 16) {
				tileSize = CGSizeMake(16,16);
			}
		} else if ([tilesetName isEqualToString:@"tiles32"]) {
			tilesetTileSize = CGSizeMake(32,32);
			maxTileSize = tilesetTileSize;
			if (tileSize.width > 32) {
				tileSize = CGSizeMake(32,32);
			}
		}
		NSString *imgName = [NSString stringWithFormat:@"%@.png", tilesetName];
		UIImage *tilesetImage = [UIImage imageNamed:imgName];
		if (!tilesetImage) {
			tilesetImage = [UIImage imageNamed:@"chozo32b.png"];
			tilesetTileSize = CGSizeMake(32,32);
			maxTileSize = tilesetTileSize;
			[[NSUserDefaults standardUserDefaults] setObject:@"chozo32b" forKey:kKeyTileset];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		tileSet = [[TileSet alloc] initWithImage:tilesetImage tileSize:tilesetTileSize];
	}
	tileSets[0] = tileSet;
	tileSets[1] = nil;
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	petMark = [[UIImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"petmark.png"]];

	shortcutView = [[ShortcutView alloc] initWithFrame:CGRectZero];
	[self addSubview:shortcutView];

	// reuse the more button
	moreButton = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
}

- (CGPoint) subViewedCenter {
	return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height-shortcutView.bounds.size.height)/2);
}

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)layoutSubviews {
	CGSize s = self.bounds.size;
	CGRect frame;
	
	s = [shortcutView sizeThatFits:s];
	frame.origin.x = (self.bounds.size.width-s.width)/2;
	frame.origin.y = self.bounds.size.height-s.height;
	frame.size.width = s.width;
	frame.size.height = s.height;
	shortcutView.frame = frame;
	
	// subviews like direction input
	for (UIView *v in self.subviews) {
		if (v != shortcutView && v != moreButton) {
			v.frame = self.frame;
		}
	}

	[shortcutView setNeedsDisplay];
}

#pragma mark drawing

- (void) drawTiledMap:(Window *)m clipRect:(CGRect)clipRect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGPoint center = self.subViewedCenter;
	center.x -= tileSize.width/2;
	center.y -= tileSize.height/2;
	
	start = CGPointMake(-mainViewController.clip.x*tileSize.width + center.x + offset.x,
						-mainViewController.clip.y*tileSize.height + center.y + offset.y);

	// indicate level boundaries
	float bgColor[] = {0.1f,0.1f,0.f,1.0f};
	float levelBgColor[] = {0.0f,0.0f,0.0f,1.0f};
	CGContextSetFillColor(ctx, bgColor);
	CGContextFillRect(ctx, clipRect);
	CGRect borderRect = CGRectMake(start.x, start.y, m.width*tileSize.width, m.height*tileSize.height);
	CGContextSetFillColor(ctx, levelBgColor);
	CGContextFillRect(ctx, borderRect);
	
	// draw version info
	CGPoint versionLocation = borderRect.origin;
	CGSize size = [bundleVersionString sizeWithFont:statusFont];
	versionLocation.x += borderRect.size.width - size.width;
	versionLocation.y += borderRect.size.height;
	float versionStringColor[] = {0.8f,0.8f,0.8f,1.0f};
	CGContextSetFillColor(ctx, versionStringColor);
	[bundleVersionString drawAtPoint:versionLocation withFont:statusFont];
	
	for (int j = 0; j < m.height; ++j) {
		for (int i = 0; i < m.width; ++i) {
			int glyph = [m glyphAtX:i y:j];
			if (glyph != kNoGlyph) {
				/*
				 // might be handy for debugging ...
				int ochar, ocolor;
				unsigned special;
				mapglyph(glyph, &ochar, &ocolor, &special, i, j);
				 */
				CGRect r = CGRectMake(start.x+i*tileSize.width, start.y+j*tileSize.height, tileSize.width, tileSize.height);
				if (CGRectIntersectsRect(clipRect, r)) {
					UIImage *img = [UIImage imageWithCGImage:[tileSet imageForGlyph:glyph atX:i y:j]];
					[img drawInRect:r];
					if (u.ux == i && u.uy == j) {
						// hp100 calculation from qt_win.cpp
						int hp100;
						if (u.mtimedone) {
							hp100 = u.mhmax ? u.mh*100/u.mhmax : 100;
						} else {
							hp100 = u.uhpmax ? u.uhp*100/u.uhpmax : 100;
						}
						const static float colorValue = 0.7f;
						float playerRectColor[] = {colorValue, 0, 0, 0.5f};
						if (hp100 > 75) {
							playerRectColor[0] = 0;
							playerRectColor[1] = colorValue;
						} else if (hp100 > 50) {
							playerRectColor[2] = 0;
							playerRectColor[0] = playerRectColor[1] = colorValue;
						}
						CGContextSetStrokeColor(ctx, playerRectColor);
						CGContextStrokeRect(ctx, r);
					} else if (glyph_is_pet(glyph)) {
						[petMark drawInRect:r];
					}
				}
			}
		}
	}
}

- (void) checkForRogueLevel {
	if (u.uz.dlevel && Is_rogue_level(&u.uz)) {
		if (!tileSets[1]) {
			tileSet = tileSets[1] = [[AsciiTileSet alloc] initWithTileSize:tilesetTileSize];
		} else {
			tileSet = tileSets[1];
		}
	} else {
		tileSet = tileSets[0];
		[tileSets[1] release];
		tileSets[1] = nil;
	}
}

- (CGSize) drawStrings:(NSArray *)strings withSize:(CGSize)size atPoint:(CGPoint)p {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	float white[] = {1,1,1,1};
	float transparentBackground[] = {0,0,0,0.6f};
	
	CGSize total = CGSizeMake(size.width, 0);
	CGRect backgroundRect = CGRectMake(p.x, p.y, size.width, size.height);
	for (NSString *s in strings) {
		UIFont *font = [self fontAndSize:&backgroundRect.size forString:s withFont:statusFont];
		CGContextSetFillColor(ctx, transparentBackground);
		CGRect backgroundRect = CGRectMake(p.x, p.y, backgroundRect.size.width, backgroundRect.size.height);
		CGContextFillRect(ctx, backgroundRect);
		CGContextSetFillColor(ctx, white);
		CGSize tmp = [s drawAtPoint:p withFont:font];
		p.y += tmp.height;
		total.height += tmp.height;
	}
	return total;
}

- (void)drawRect:(CGRect)rect {
	mainViewController = [MainViewController instance];
	
	// retain needed windows to avoid crash on exit
	self.map = mainViewController.mapWindow;
	self.status = mainViewController.statusWindow;
	self.message = mainViewController.messageWindow;
	
	CGPoint center = self.subViewedCenter;

	if (map) {
		[self checkForRogueLevel];
		[self drawTiledMap:map clipRect:rect];
		if (map.blocking) {
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			float white[] = {1.0f,1.0f,1.0f,1.0f};
			CGContextSetFillColor(ctx, white);
			NSString *m = @"Single tap to continue ...";
			CGSize size = [m sizeWithFont:statusFont];
			center.x -= size.width/2;
			center.y -= size.height/2;
			[m drawAtPoint:center withFont:statusFont];
		}
	}
	
	CGSize statusSize = CGSizeMake(0,0);
	CGPoint p = CGPointMake(0,0);
	if (status) {
		NSArray *strings = nil;
		[status lock];
		strings = [status.strings copy];
		[status unlock];
		if (strings.count > 0) {
			statusSize = [self drawStrings:[strings copy] withSize:CGSizeMake(self.bounds.size.width, 18)
								   atPoint:p];
		}
	}
	if (message) {
		[moreButton removeFromSuperview];
		CGSize avgLineSize = [@"O" sizeWithFont:statusFont];
		float maxY = center.y - avgLineSize.height*2;
		p.y = statusSize.height;
		NSArray *strings = nil;
		[message lock];
		strings = [message.strings copy];
		[message unlock];
		if (strings.count > 0) {
			CGSize bounds = self.bounds.size;
			for (NSString *s in strings) {
				CGSize size = [s sizeWithFont:statusFont];
				if (p.y > maxY) {
					p.x = 0;
					p.y += size.height + 2;
					CGRect frame = moreButton.frame;
					frame.origin = p;
					moreButton.frame = frame;
					[moreButton addTarget:[MainViewController instance] action:@selector(nethackShowLog:)
						 forControlEvents:UIControlEventTouchUpInside];
					[self addSubview:moreButton];
					break;
				}
				if (p.x + size.width < bounds.width) {
					size = [s drawAtPoint:p withFont:statusFont];
					p.x += size.width + 4;
				} else {
					if (p.x != 0) {
						p.y += size.height + 2;
					}
					p.x = 0;
					UIFont *font = [self fontAndSize:&size forString:s withFont:statusFont];
					size = [s drawAtPoint:p withFont:font];
					p.x += size.width;
				}
			}
		}
	}
}

- (TilePosition *) tilePositionFromPoint:(CGPoint)p {
	p.x -= start.x;
	p.y -= start.y;
	TilePosition *tp = [TilePosition tilePositionWithX:p.x/tileSize.width y:p.y/tileSize.height];
	return tp;
}

- (UIFont *) fontAndSize:(CGSize *)size forStrings:(NSArray *)strings withFont:(UIFont *)font {
	CGSize dummySize;
	if (!size) {
		size = &dummySize;
	}
	*size = CGSizeMake(0,0);
	CGFloat maxWidth = self.bounds.size.width;
	for (NSString *s in strings) {
		CGSize tmpSize = [s sizeWithFont:font];
		while (tmpSize.width > maxWidth) {
			font = [font fontWithSize:font.pointSize-1];
			tmpSize = [s sizeWithFont:font];
		}
		size->width = tmpSize.width > size->width ? tmpSize.width:size->width;
		size->height += tmpSize.height;
	}
	return font;
}

- (UIFont *) fontAndSize:(CGSize *)size forString:(NSString *)s withFont:(UIFont *)font {
	CGSize dummySize;
	if (!size) {
		size = &dummySize;
	}
	*size = CGSizeMake(0,0);
	CGFloat maxWidth = self.bounds.size.width;
	CGSize tmpSize = [s sizeWithFont:font];
	while (tmpSize.width > maxWidth) {
		font = [font fontWithSize:font.pointSize-1];
		tmpSize = [s sizeWithFont:font];
	}
	size->width = tmpSize.width > size->width ? tmpSize.width:size->width;
	size->height += tmpSize.height;
	return font;
}

- (void) drawStrings:(NSArray *)strings atPosition:(CGPoint)p {
	UIFont *f = statusFont;
	CGFloat width = self.bounds.size.width;
	CGFloat height = 0;
	for (NSString *s in strings) {
		CGSize size = [s sizeWithFont:f];
		while (size.width > width) {
			CGFloat pointSize = f.pointSize-1;
			statusFont = [UIFont systemFontOfSize:pointSize];
			size = [s sizeWithFont:f];
		}
		height = size.height > height ? size.height:height;
	}
}

- (void) moveAlongVector:(CGPoint)d {
	offset.x += d.x;
	offset.y += d.y;
}

- (void) resetOffset {
	offset = CGPointMake(0,0);
}

- (void) zoom:(CGFloat)d {
	d /= 5;
	CGSize originalSize = tileSize;
	tileSize.width += d;
	tileSize.width = round(tileSize.width);
	tileSize.height = tileSize.width;
	if (tileSize.width > maxTileSize.width) {
		tileSize = maxTileSize;
	} else if (tileSize.width < minTileSize.width) {
		tileSize = minTileSize;
	}
	CGFloat aspect = tileSize.width / originalSize.width;
	offset.x *= aspect;
	offset.y *= aspect;
	[self setNeedsDisplay];
}

- (BOOL) isMoved {
	if (offset.x != 0 || offset.y != 0) {
		return YES;
	}
	return NO;
}

- (void)dealloc {
	[tileSets[0] release];
	[tileSets[1] release];
	[shortcutView release];
	[petMark release];
	[bundleVersionString release];
    [super dealloc];
}

@end
