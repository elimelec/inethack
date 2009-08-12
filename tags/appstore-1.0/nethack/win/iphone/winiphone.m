/*
 *  iphone.c
 *  iNetHack
 *
 *  Created by dirk on 6/26/09.
 *  Copyright 2009 Dirk Zimmermann. All rights reserved.
 *
 */

//  This file is part of iNetHack.
//
//  iNetHack is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  iNetHack is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with iNetHack.  If not, see <http://www.gnu.org/licenses/>.

#import "winiphone.h"
#import "MainViewController.h"
#import "Window.h"
#import "NethackMenuItem.h"
#import "NethackYnFunction.h"
#import "NethackEvent.h"
#import "NethackEventQueue.h"

#include <stdio.h>
#include "dlb.h"

#undef DEFAULT_WINDOW_SYS
#define DEFAULT_WINDOW_SYS "iphone"

struct window_procs iphone_procs = {
"iphone",
WC_COLOR|WC_HILITE_PET|
WC_ASCII_MAP|WC_TILED_MAP|
WC_FONT_MAP|WC_TILE_FILE|WC_TILE_WIDTH|WC_TILE_HEIGHT|
WC_PLAYER_SELECTION|WC_SPLASH_SCREEN,
0L,
iphone_init_nhwindows,
iphone_player_selection,
iphone_askname,
iphone_get_nh_event,
iphone_exit_nhwindows,
iphone_suspend_nhwindows,
iphone_resume_nhwindows,
iphone_create_nhwindow,
iphone_clear_nhwindow,
iphone_display_nhwindow,
iphone_destroy_nhwindow,
iphone_curs,
iphone_putstr,
iphone_display_file,
iphone_start_menu,
iphone_add_menu,
iphone_end_menu,
iphone_select_menu,
genl_message_menu,	  /* no need for X-specific handling */
iphone_update_inventory,
iphone_mark_synch,
iphone_wait_synch,
#ifdef CLIPPING
iphone_cliparound,
#endif
#ifdef POSITIONBAR
donull,
#endif
iphone_print_glyph,
iphone_raw_print,
iphone_raw_print_bold,
iphone_nhgetch,
iphone_nh_poskey,
iphone_nhbell,
iphone_doprev_message,
iphone_yn_function,
iphone_getlin,
iphone_get_ext_cmd,
iphone_number_pad,
iphone_delay_output,
#ifdef CHANGE_COLOR	 /* only a Mac option currently */
donull,
donull,
#endif
/* other defs that really should go away (they're tty specific) */
iphone_start_screen,
iphone_end_screen,
iphone_outrip,
genl_preference_update,
};

void process_options(int argc, char *argv[]) {
	[[MainViewController instance] initOptions];
	iflags.use_color = TRUE;
}

FILE *iphone_fopen(const char *filename, const char *mode) {
	NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:filename] ofType:@""];
	const char *pathc = [path cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
	FILE *file = fopen(pathc, mode);
	return file;
}

void intron() {
	NSLog(@"intron");
}

void introff() {
	NSLog(@"introff");
}

int dosuspend() {
	NSLog(@"dosuspend");
	return 0;
}

int dosh() {
	NSLog(@"dosh");
	return 0;
}

void error(const char *s, ...) {
	// todo
	NSLog(@"error: %s");
	exit(0);
}

void regularize(char *s) {
	NSLog(@"regularize %s", s);
}

int child(int wt) {
	NSLog(@"child %d", wt);
	return 0;
}

#pragma mark nethack window system API

void iphone_init_nhwindows(int* argc, char** argv) {
	iflags.window_inited = TRUE;
}

void iphone_player_selection() {
	//strcpy(pl_character, "Barb");
	[[MainViewController instance] doPlayerSelection];
}

void iphone_askname() {
	NSString *name = [[MainViewController instance] askName];
	[name getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
}

void iphone_get_nh_event() {
	//NSLog(@"iphone_get_nh_event");
}

void iphone_exit_nhwindows(const char *str) {
	NSLog(@"iphone_exit_nhwindows %s", str);
}

void iphone_suspend_nhwindows(const char *str) {
	NSLog(@"iphone_suspend_nhwindows %s", str);
}

void iphone_resume_nhwindows() {
	NSLog(@"iphone_resume_nhwindows");
}

winid iphone_create_nhwindow(int type) {
	winid wid = [[MainViewController instance] createWindow:type];
	//NSLog(@"iphone_create_nhwindow(%d) -> %d", type, wid);
	return wid;
}

void iphone_clear_nhwindow(winid wid) {
	//NSLog(@"iphone_clear_nhwindow %d", wid);
	Window *w = [[MainViewController instance] windowWithId:wid];
	[w clear];
}

void iphone_display_nhwindow(winid wid, BOOLEAN_P block) {
	//NSLog(@"iphone_display_nhwindow %d", wid);
	[[MainViewController instance] displayWindowId:wid blocking:block ? YES:NO];
}

void iphone_destroy_nhwindow(winid wid) {
	//NSLog(@"iphone_destroy_nhwindow %d", wid);
	[[MainViewController instance] destroyWindow:wid];
}

void iphone_curs(winid wid, int x, int y) {
	//NSLog(@"iphone_curs %d %d,%d", wid, x, y);
}

void iphone_putstr(winid wid, int attr, const char *text) {
	//NSLog(@"iphone_putstr %d %s", wid, text);
	Window *w = [[MainViewController instance] windowWithId:wid];
	[w putString:text];
}

void iphone_display_file(const char *filename, BOOLEAN_P must_exist) {
	//NSLog(@"iphone_display_file %s", filename);
	[[MainViewController instance] displayFile:[NSString stringWithCString:filename] mustExist:must_exist?YES:NO];
}

void iphone_start_menu(winid wid) {
	//NSLog(@"iphone_start_menu %d", wid);
	Window *w = [[MainViewController instance] windowWithId:wid];
	[w startMenu];
}

void iphone_add_menu(winid wid, int glyph, const ANY_P *identifier,
					 CHAR_P accelerator, CHAR_P group_accel, int attr, 
					 const char *str, BOOLEAN_P presel) {
	//NSLog(@"iphone_add_menu %d %s", wid, str);
	NethackMenuItem *i = [[NethackMenuItem alloc] initWithId:identifier title:str preselected:presel?YES:NO];
	Window *w = [[MainViewController instance] windowWithId:wid];
	[w addMenuItem:i];
	[i release];
}

void iphone_end_menu(winid wid, const char *prompt) {
	//NSLog(@"iphone_end_menu %d, %s", wid, prompt);
	if (prompt) {
		Window *w = [[MainViewController instance] windowWithId:wid];
		w.menuPrompt = [NSString stringWithCString:prompt];
	}
}

int iphone_select_menu(winid wid, int how, menu_item **menu_list) {
	NSLog(@"iphone_select_menu %x", wid);
	Window *w = [[MainViewController instance] windowWithId:wid];
	w.menuHow = how;
	[[MainViewController instance] displayMenuWindow:w];
	*menu_list = w.menuList;
	NSLog(@"iphone_select_menu -> %d", w.menuResult);
	return w.menuResult;
}

void iphone_update_inventory() {
	//NSLog(@"iphone_update_inventory");
}

void iphone_mark_synch() {
	//NSLog(@"iphone_mark_synch");
}

void iphone_wait_synch() {
	//NSLog(@"iphone_wait_synch");
}

void iphone_cliparound(int x, int y) {
	//NSLog(@"iphone_cliparound %d,%d", x, y);
	MainViewController *v = [MainViewController instance];
	v.clipx = x;
	v.clipy = y;
}

void iphone_cliparound_window(winid wid, int x, int y) {
	NSLog(@"iphone_cliparound_window %d %d,%d", wid, x, y);
}

void iphone_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph) {
	//NSLog(@"iphone_print_glyph %d %d,%d", wid, x, y);
	Window *w = [[MainViewController instance] windowWithId:wid];
	[w setGlyph:glyph atX:x y:y];
}

void iphone_raw_print(const char *str) {
	NSLog(@"iphone_raw_print %s", str);
}

void iphone_raw_print_bold(const char *str) {
	NSLog(@"iphone_raw_print_bold %s", str);
}

int iphone_nhgetch() {
	NSLog(@"iphone_nhgetch");
	return 0;
}

int iphone_nh_poskey(int *x, int *y, int *mod) {
	//NSLog(@"iphone_nh_poskey");
	MainViewController *v = [MainViewController instance];
	NethackEvent *e = [v.nethackEventQueue waitForNextEvent];
	*x = e.x;
	*y = e.y;
	*mod = CLICK_1;
	return e.key;
}

void iphone_nhbell() {}

int iphone_doprev_message() {
	NSLog(@"iphone_doprev_message");
	return 0;
}

char iphone_yn_function(const char *question, const char *choices, CHAR_P def) {
	NSLog(@"iphone_yn_function %s", question);
	if (!choices) {
		NSString *s = [NSString stringWithCString:question];
		if ([s isEqualToString:@"In what direction?"] || [s isEqualToString:@"Talk to whom? (in what direction)"]) {
			return [[MainViewController instance] getDirectionInput];
		} else {
			NSRange r = [s rangeOfString:@"*"];
			if (r.location != NSNotFound) {
				[[MainViewController instance] setPrompt:[NSString stringWithCString:question]];
				return '*';
			} else {
				// try to quit
				NSRange r = [s rangeOfString:@"q"];
				if (r.location != NSNotFound) {
					return 'q';
				} else {
					r = [s rangeOfString:@"n"];
					if (r.location != NSNotFound) {
						return 'n';
					} else {
						NSLog(@"can't cancel yn_function %s", question);
						// return q anyway
						return 'q';
					}
				}
			}
		}
	} else {
		NSString *s = [NSString stringWithCString:question];
		if ([s isEqualToString:@"Really save?"]) {
			return 'y';
		} 
		NethackYnFunction *yn = [[NethackYnFunction alloc] initWithQuestion:question choices:choices defaultChoice:def];
		[[MainViewController instance] displayYnQuestion:yn];
		[yn autorelease];
		return yn.choice;
	}
}

void iphone_getlin(const char *prompt, char *line) {
	NSLog(@"iphone_getlin %s", prompt);
	[[MainViewController instance] getLine:line prompt:prompt];
}

int iphone_get_ext_cmd() {
	return [[MainViewController instance] getExtendedCommand];
}

void iphone_number_pad(int num) {
	NSLog(@"iphone_number_pad %d", num);
}

void iphone_delay_output() {
	NSLog(@"iphone_delay_output");
}

void iphone_start_screen() {
	NSLog(@"iphone_start_screen");
}

void iphone_end_screen() {
	NSLog(@"iphone_end_screen");
}

void iphone_outrip(winid wid, int how) {
	NSLog(@"iphone_outrip %d", wid);
}

void iphone_main() {
	int argc = 0;
	char **argv = NULL;
	
	// create save directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths lastObject];
	saveDirectory = [saveDirectory stringByAppendingPathComponent:@"nethack"];
	NSString *currentDirectory = [NSString stringWithString:saveDirectory];
	saveDirectory = [saveDirectory stringByAppendingPathComponent:@"save"];
	NSLog(@"saveDirectory %@", saveDirectory);
	if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory]) {
		BOOL succ = [[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES
															   attributes:nil error:nil];
		if (!succ) {
			NSLog(@"saveDirectory could not be created!");
		}
	}
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:currentDirectory];
	NSArray *filelist = [[NSFileManager defaultManager] directoryContentsAtPath:saveDirectory];
	for (NSString *filename in filelist) {
		NSLog(@"file %@", filename);
	}
	
	choose_windows(DEFAULT_WINDOW_SYS); /* choose a default window system */
	initoptions();			   /* read the resource file */
	
	init_nhwindows(&argc, argv);		   /* initialize the window system */
	process_options(argc, argv);	   /* process command line options or equiv */
	
	dlb_init();
	vision_init();
	display_gamewindows();		   /* create & display the game windows */

	register int fd;
	if ((fd = restore_saved_game()) >= 0) {
#ifdef WIZARD
		/* Since wizard is actually flags.debug, restoring might
		 * overwrite it.
		 */
		boolean remember_wiz_mode = wizard;
#endif
		const char *fq_save = fqname(SAVEF, SAVEPREFIX, 1);
		
		//(void) chmod(fq_save,0);	/* disallow parallel restores */
		(void) signal(SIGINT, (SIG_RET_TYPE) done1);
#ifdef NEWS
		if(iflags.news) {
		    display_file(NEWS, FALSE);
		    iflags.news = FALSE; /* in case dorecover() fails */
		}
#endif
		pline("Restoring save file...");
		mark_synch();	/* flush output */
		if(!dorecover(fd))
			goto not_recovered;
#ifdef WIZARD
		if(!wizard && remember_wiz_mode) wizard = TRUE;
#endif
		check_special_room(FALSE);
		//wd_message();
		
		if (discover || wizard) {
			if(yn("Do you want to keep the save file?") == 'n') {
				// todo allows cheating but also saves from crashes
			    //(void) delete_savefile();
			}
			else {
			    //(void) chmod(fq_save,FCMASK); /* back to readable */
			    compress(fq_save);
			}
		}
		flags.move = 0;
	} else {
	not_recovered:
		player_selection();
		newgame();
		//wd_message();
		
		flags.move = 0;
		set_wear();
		(void) pickup(1);
	}
	
	[[MainViewController instance] overrideOptions];
	moveloop();
	exit(EXIT_SUCCESS);
}