# Squid Proxy Config

A configuration file for Squid Proxy in whitelist mode (deny all, allow some) with some interesting features. It was made for the Windows port of version 3.5.28.

![log example](https://i.imgur.com/lBEAYhB.png)

## Features

- SSL bumping configured to bump every domain not included in the whitelist. If you want the inverse, bumping only the domains included in a list, it's already preset in the configuration, just follow the instructions there.
- Automatically allows domains accessed from Google Search.
- Automatically allows every image, video and CSS whose MIME type matches the file type.
- For your convenience, it also includes a whitelist file with a pre-made collection of sites that require lots of domains to be allowed. It's expected that you won't need all of them, so just remove the ones you don't need, they are all grouped by ASN and by site, so it's easy to find.
