## opentracker - open-source and free BitTorrent tracker

**opentracker** is a open and free [bittorrent tracker](http://wiki.theory.org/BitTorrentSpecification) project. It aims for minimal resource usage and is intended to run at your wlan router. Currently it is deployed as an open and free tracker instance.

### Build instructions

You need docker.

**Steps to go:**

`make docker`

That should leave you with an exectuable called `opentracker` and one debug version `opentracker.debug`.

This tracker is open in a sense that everyone announcing a torrent is welcome to do so and will be informed about anyone else announcing the same torrent. Unless
`-DWANT_IP_FROM_QUERY_STRING` is enabled (which is meant for debugging purposes only), only source IPs are accepted. The tracker implements a minimal set of
essential features only but was able respond to far more than 10000 requests per second on a Sun Fire 2200 M2 (thats where we found no more clients able to fire
more of our `testsuite.sh` script).

Some variables in opentracker's `Makefile` control features and behaviour of opentracker. Here they are:

- `-DWANT_V6` makes opentracker an IPv6-only tracker. More in the v6-section below.

- opentracker can deliver gzip compressed full scrapes. Enable this with `-DWANT_COMPRESSION_GZIP` option.

- Normally opentracker tracks any torrent announced to it. You can change that behaviour by enabling ONE of `-DWANT_ACCESSLIST_BLACK` or `-DWANT_ACCESSLIST_WHITE`. Note, that you have to provide a whitelist file in order to make opentracker do anything in the latter case. More in the closed mode section below.

- opentracker can run in a cluster. Enable this behaviour by enabling `-DWANT_SYNC_LIVE`. Note, that you have to configure your cluster before you can use opentracker when this option is on.

- Some statistics opentracker can provide are sensitive. You can restrict access to these statistics by enabling `-DWANT_RESTRICT_STATS`. See section statistics for more details.

- Fullscrapes is bittorrent's way to query a tracker for all tracked torrents. Since it's in the standard, it is enabled by default. Disable it by commenting out `-DWANT_FULLSCRAPE`.

- By default opentracker will only allow the connecting endpoint's IP address to be announced. Bittorrent standard allows clients to provide an IP address in its query string. You can make opentracker use this IP address by enabling -`DWANT_IP_FROM_QUERY_STRING`.

- Some experimental or older, deprecated features can be enabled by the -`DWANT_LOG_NETWORKS`, -`DWANT_SYNC_SCRAPE` or -`DWANT_IP_FROM_PROXY` switch.

Currently there is some packages for some linux distributions and OpenBSD around, but some of them patch Makefile and default config to make opentracker closed by default. I explicitly don't endorse those packages and will not give support for problems stemming from these missconfigurations.

Some tweaks you may want to try under FreeBSD:

    sysctl kern.ipc.somaxconn=1024
    sysctl kern.ipc.nmbclusters=32768
    sysctl net.inet.tcp.msl=10000
    sysctl kern.maxfiles=10240

### Invocation

`opentracker` can be run by just typing `./opentracker`. This will make opentracker bind to 0.0.0.0:6969 and happily serve all torrents presented to it. If ran as root, opentracker will immediately chroot to . (or any directory given with the `-d` option) and drop all priviliges after binding to whatever tcp or udp ports it is requested.

When options were few, _opentracker_ used to accept all of them from command line. While this still is possible for most options, using them is quite unhandy: an example invocation would look like:

    ./opentracker -i 23.23.23.7 -p 80 -P 80 -p 6969 -i 23.23.23.8 -p 80 -r http://www.mytorrentsite.com/ -d /usr/local/etc/opentracker -w mytorrents.list -A 127.0.0.1

opentracker now uses a config file that you can provide with the `-f` switch.

### Config file

_opentrackers_ config file is very straight forward and a very well documented example config can be found in the file opentracker.conf.sample.

### Closed mode

While personally I like my tracker to be open, I can see that there's people that want to control what torrents to track – or not to track. If you've compiled _opentracker_ with one of the accesslist-options (see Build instructions above), you can control which torrents are tracked by providing a file that contains a list of human readable info_hashes. An example whitelist file would look like:

    0123456789abcdef0123456789abcdef01234567
    890123456789abcdef0123456789abcdef012345

To make opentracker reload it's white/blacklist, send a `SIGHUP` unix signal.

### Statistics

Given its very network centric approach, talking to opentracker via http comes very naturally. Besides the `/announce` and `/scrape` paths, there is a third path you can access the tracker by: `/stats`. This request takes parameters, for a quick overview just inquire `/stats?mode=everything`.

Statistics have grown over time and are currently not very tidied up. Most modes were written to dump legacy-SNMP-style blocks that can easily be monitored by MRTG. These modes are: `peer, conn, scrp, udp4, tcp4, busy, torr, fscr, completed, syncs`. I'm not going to explain these here.

The `statedump` mode dumps non-recreatable states of the tracker so you can later reconstruct an _opentracker_ session with the `-l` option. This is beta and wildly undocumented.

You can inquire opentracker's version (i.e. CVS versions of all its objects) using the version mode.

### Philosophy

A torrent tracker basically is an http-Server that collects all clients ip addresses into pools sorted by one of the request strings parameters and answers all other clients that specified this exact same parameter a list of all other recent clients. All technologies to implement this are around for more than twenty years. Still most implementations suck performancewise.

Utilizing the highly scalable server framework from [libowfat](https://github.com/masroore/libowfat), opentracker can easily serve multiple thousands of requests on a standard plastic WLAN-router, limited only by your kernels capabilities ;)

One important design decision of opentracker was to not store any data persistently. This reduces wear&tear on hard disks and eliminates problems with corrupt databases.

### Author

_opentracker_ was written by Dirk Engling, who likes to hear from happy customers. His mail address is erdgeist@erdgeist.org

### Thanks

A project like this one is impossible without lots of help from friends. It is powered by beer, much energy and love, batches of bug reports and support on the operating system integration side by denis, taklamakan, cryx, supergrobi and – his libowfat always on the bleeding edge – Fefe. Thanks are also due to Hannes for helping me out with designing internal data representation.

### License

opentracker is considered [beer ware](http://en.wikipedia.org/wiki/Beerware)

Although the libowfat library is under GPL, Felix von Leitner agreed that the compiled binary may be distributed under the same beer ware license as the source code for opentracker. However, we like to hear from happy customers.
