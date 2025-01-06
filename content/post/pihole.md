---
title: "PiHole - PiHole Recursive DNS"
description: "How to setup your own recursive dns."
date: 2022-08-29T12:17:22+01:00
draft: true
---

Pi-hole is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole intended for use on a private network.
It can also be extended to be it's own recursive DNS server.

Let's start by installing PiHole.
Simply run the following command and follow it's instructions:

```sh
$ curl -sSL https://install.pi-hole.net | bash
```

PiHole should now be installed.
Make sure to configure your own router settings so that your system serves as the default DNS server for the network.

# 1. Unbound

Now let's turn our PiHole instalation into it's own recursive DNS server.

Start by installing unbound through your favorite package manager. Possibly by running:

```sh
$ sudo apt install unbound
```

Once you have unbound installed, run the following command to make sure you have the root.hints file properly installed:

```sh
$ wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints
```

Now let's configure unbound.
Run the next three commands.

Edit unbound configuration.

```sh
$ cat << EOF > /etc/unbound/unbound.conf.d/pi-hole.conf
server:

    # The  verbosity  number, level 0 means no verbosity, only errors.
    # Level 1 gives operational information. Level  2  gives  detailed
    # operational  information. Level 3 gives query level information,
    # output per query.  Level 4 gives  algorithm  level  information.
    # Level 5 logs client identification for cache misses.  Default is
    # level 1.
    verbosity: 0

    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # May be set to yes if you have IPv6 connectivity
    do-ip6: no

    # You want to leave this to no unless you have *native* IPv6. With 6to4 and
    # Terredo tunnels your web browser should favor IPv4 for the same reasons
    prefer-ip6: no

    # Use this only when you downloaded the list of primary root servers!
    # Read  the  root  hints from this file. Make sure to
    # update root.hints evry 5-6 months.
    root-hints: "/var/lib/unbound/root.hints"

    # Trust glue only if it is within the servers authority
    harden-glue: yes

    # Ignore very large queries.
    harden-large-queries: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
    # If you want to disable DNSSEC, set harden-dnssec stripped: no
    harden-dnssec-stripped: yes

    # Number of bytes size to advertise as the EDNS reassembly buffer
    # size. This is the value put into  datagrams over UDP towards
    # peers. The actual buffer size is determined by msg-buffer-size
    # (both for TCP and UDP).
    edns-buffer-size: 1232

    # Rotates RRSet order in response (the pseudo-random
    # number is taken from Ensure privacy of local IP
    # ranges the query ID, for speed and thread safety).
    # private-address: 192.168.0.0/16
    rrset-roundrobin: yes

    # Time to live minimum for RRsets and messages in the cache. If the minimum
    # kicks in, the data is cached for longer than the domain owner intended,
    # and thus less queries are made to look up the data. Zero makes sure the
    # data in the cache is as the domain owner intended, higher values,
    # especially more than an hour or so, can lead to trouble as the data in
    # the cache does not match up with the actual data anymore
    cache-min-ttl: 300
    cache-max-ttl: 86400

    # Have unbound attempt to serve old responses from cache with a TTL of 0 in
    # the response without waiting for the actual resolution to finish. The
    # actual resolution answer ends up in the cache later on.
    serve-expired: yes

    # Harden against algorithm downgrade when multiple algorithms are
    # advertised in the DS record.
    harden-algo-downgrade: yes

    # Ignore very small EDNS buffer sizes from queries.
    harden-short-bufsize: yes

    # Refuse id.server and hostname.bind queries
    hide-identity: yes

    # Report this identity rather than the hostname of the server.
    identity: "Server"

    # Refuse version.server and version.bind queries
    hide-version: yes

    # Prevent the unbound server from forking into the background as a daemon
    do-daemonize: no

    # Number  of  bytes size of the aggressive negative cache.
    neg-cache-size: 4m

    # Send minimum amount of information to upstream servers to enhance privacy
    qname-minimisation: yes

    # Deny queries of type ANY with an empty response.
    # Works only on version 1.8 and above
    deny-any: yes

    # Do no insert authority/additional sections into response messages when
    # those sections are not required. This reduces response size
    # significantly, and may avoid TCP fallback for some responses. This may
    # cause a slight speedup
    minimal-responses: yes

    # Perform prefetching of close to expired message cache entries
    # This only applies to domains that have been frequently queried
    # This flag updates the cached domains
    prefetch: yes

    # Fetch the DNSKEYs earlier in the validation process, when a DS record is
    # encountered. This lowers the latency of requests at the expense of little
    # more CPU usage.
    prefetch-key: yes

    # One thread should be sufficient, can be increased on beefy machines. In reality for
    # most users running on small networks or on a single machine, it should be unnecessary
    # to seek performance enhancement by increasing num-threads above 1.
    num-threads: 1

    # more cache memory. rrset-cache-size should twice what msg-cache-size is.
    msg-cache-size: 50m
    rrset-cache-size: 100m

    # Faster UDP with multithreading (only on Linux).
    so-reuseport: yes

    # Ensure kernel buffer is large enough to not lose messages in traffix spikes
    so-rcvbuf: 4m
    so-sndbuf: 4m

    # Set the total number of unwanted replies to keep track of in every thread.
    # When it reaches the threshold, a defensive action of clearing the rrset
    # and message caches is taken, hopefully flushing away any poison.
    # Unbound suggests a value of 10 million.
    unwanted-reply-threshold: 100000

    # Minimize logs
    # Do not print one line per query to the log
    log-queries: no
    # Do not print one line per reply to the log
    log-replies: no
    # Do not print log lines that say why queries return SERVFAIL to clients
    log-servfail: no
    # Do not print log lines to inform about local zone actions
    log-local-actions: no
    # Do not print log lines that say why queries return SERVFAIL to clients
    logfile: /dev/null

    # Ensure privacy of local IP ranges
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10
EOF
```

Remove unbound configuration from resolvconf.

```sh
$ cat << EOF > /etc/resolvconf.conf
# Configuration for resolvconf(8)
# See resolvconf.conf(5) for details

resolv_conf=/etc/resolv.conf
# If you run a local name server, you should uncomment the below line and
# configure your subscribers configuration files below.
#name_servers=127.0.0.1


# Mirror the Debian package defaults for the below resolvers
# so that resolvconf integrates seemlessly.
dnsmasq_resolv=/var/run/dnsmasq/resolv.conf
pdnsd_conf=/etc/pdnsd.conf
EOF
```

Remove unbound resolvconf file.

```sh
$ sudo rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf
```

Finally restart your unbound service.

```sh
$ sudo systemctl restart unbound.service
```

# 2. Configuring PiHole

Set a new password for PiHole admin console:

```sh
$ pihole -a -p
```

Go to [pi.hole/admin](http://pi.hole/admin) on your browser and log in.

Update your DNS settings and make sure to desellect all upstream DNS servers and add `localhost#5335` as a custom DNS.

{{% figure class="image" src="/images/pihole/dns-settings.png" title="PiHole DNS Settings" caption="" %}}

You now have a privacy preserving recursive DNS server.

# 3. (Bonus) PiVPN

Now that you've configured your own privacy preserving recursive dns, you might want to use it even when outside your own network.

Let's create a vpn by installing PiVPN.
Once more run the following command and follow it's instructions:

```sh
$ curl -L https://install.pivpn.io | bash
```

PiVPN should now be installed.
Make sure to configure your router's port forwarding settings so that port `1194` is redirected to your system.

You can create client interfaces by running:

```sh
$ pivpn add
```

Once your client interface is created, you can generate a qr code for it by running:

```sh
$ pivpn -qr
```
