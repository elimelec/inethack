Ever since the iPhone came out I waited patiently for a NetHack port, but over the years none came. I did some rogue porting, looked at umoria, powder and others but never followed through.

One morning I woke up and decided that I've waited far too long. That's the day I noticed a new [port project](http://code.google.com/p/iphone-nethack/). I talked with the developers and then decided I'd watch what happens.

When after 10 days or so nothing had happened I've finally had enough of waiting for a port and started implementing. I also thought that since NetHack has nice support for win infrastructure it would be a 3-day job, maybe a week to polish it :)

The things I copied is the winiphone stubs (I removed the implementation because I had a slightly different architecture) and some interaction with the NetHack core (like the declaration of the stubs as procs, the fopen implementation etc.) and the first main implementation (though I later replaced that with another port, the tty I think).