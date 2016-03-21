# Introduction #

**There's usually no need to do this, and I'm pretty sure it's not complete.**

# Details #

All commands to be executed from nethack top level directory. **Remember that Snow Leopard builds NetHack 64 bit by default**.

Create makefiles:

**Note** that for some patches to work (e.g. Jedi for Slash'EM) you might have to omit the arg for setup.sh so the Makefiles are copied not symlinked.

  * cd sys/unix; sh setup.sh arg # for symbolic links
  * use -arch i386 in the makefiles you use
```
CFLAGS = -arch i386 -O -I../include
LFLAGS = -m32
```

Create date.h, pm.h, Onames.h etc.:

  * cd util ; make
  * cd src ; ../util/makedefs -v # date.h
  * cd src ; ../util/makedefs -p # pm.h
  * cd src ; ../util/makedefs -o # Onames.h, dat/options?
  * cd src ; ../util/makedefs -m # monstr.c
  * cd src ; ../util/makedefs -f # filename.h

Recompile dungeons:

  * cd dat ; make

Some additional targets you have to update occasionally:

  * cd src ; make tile.c

Extrea clean

  * make spotless