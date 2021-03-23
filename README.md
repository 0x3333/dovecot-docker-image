Dovecot Docker Image
====================



## Supported tags and respective `Dockerfile` links

- `2.3.14.0`, `2.3.14`, `2.3`, `2`, `latest` [(debian/Dockerfile)][101]
- `2.3.14.0-alpine`, `2.3.14-alpine`, `2.3-alpine`, `2-alpine`, `alpine` [(alpine/Dockerfile)][102]




## What is Dovecot?

[Dovecot][10] is an open-source IMAP and POP3 server for Linux/UNIX-like systems, written primarily with security in mind. Timo Sirainen originated Dovecot and first released it in July 2002. Dovecot developers primarily aim to produce a lightweight, fast and easy-to-set-up open-source mailserver.

Dovecot is an excellent choice for both small and large installations. It's fast, simple to set up, requires no special administration and it uses very little memory.

> [dovecot.org](https://dovecot.org)

![Dovecot Logo](https://dovecot.org/dovecot.gif)




## How to use this image

To run Dovecot with default configuration simply do: 
```bash
docker run -d -p 143:143 0x3333/dovecot
```

To see default configuration just run:
```bash
docker run --rm 0x3333/dovecot doveconf
```

To reconfigure Dovecot add/replace drop-in files in `/etc/dovecot/conf.d/` directory inside container, or just specify your own `/etc/dovecot/dovecot.conf` file:
```bash
docker run -d -p 143:143 -v /my/dovecot.cnf:/etc/dovecot/dovecot.conf 0x3333/dovecot
```




## Image versions


### `X`

Latest version of `X` Dovecot major version.


### `X.Y`

Latest version of `X.Y` Dovecot minor version.


### `X.Y.Z`

Concrete `X.Y.Z` version of Dovecot with latest updates applied.


### `X.Y.Z.P`

Concrete `X.Y.Z` version of Dovecot with `P` update applied.


### `alpine`

This image is based on the popular [Alpine Linux project][1], available in [the alpine official image][2]. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc][4] instead of [glibc and friends][5], so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread][6] for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.



## 0x3333 Fork Changes

This fork has been created to a specific purpose, email archiving. It have will allow 2 users to the same mailbox, one that is `rw` and another one that is readonly. The `rw` one will be appended with the domain `@rw` and will be given a default password stored on `/var/mail/rw-password` file(This user is used to store emails in the mailbox). There is ACLs inplace that will manage this `rw`/`ro` situation. The readonly account is to be used to search the email archive.

Changes:

* Updated Dovecot
* Updated Alpine
* Added Solr support
* Configured mailbox to be compressed by LZ4
* Removed support for `auth-passwdfile`
* Fixed empty lines on generated `Dockerfile`
* Disabled SSL by default(Still hardening)
* Added 2 links to `/etc/dovecot/`, `users` and `acls`, makes it easy to a volume on the container. See note 1.
* Disable PAM authentication
* Enabled on IMAP
* Added configuration for local passwd file authentication only
* Added 2 scripts to manage users(`doveadduser` and `dovedeluser`)
* Enabled plaintext authentication on no *NON-SECURE* connection. See note 2.
* Added master user support with RW ACL


## License

Dovecot itself is licensed under [LGPLv2.1][93] and [MIT][94] licenses (see [details][92]).

Dovecot Docker image is licensed under [MIT license][91].




## Issues

We can't notice comments in the DockerHub so don't use them for reporting issue or asking question.

If you have any problems with or questions about this image, please contact us through a [GitHub issue][3].


## Notes

1. Create 2 files inside the volume mounted on `/var/mail`, named `dovecot-users` and `dovecot-acls`, they will be linked to `/etc/dovecot/users` and `/etc/dovecot/acls`. No need to mount these files separately.
2. This implementation TLS/SSL has been disable, as this application is running inside a private network, without external connection. Plaintext authentication has been enabled.


[1]: http://alpinelinux.org
[2]: https://hub.docker.com/_/alpine
[3]: https://github.com/instrumentisto/dovecot-docker-image/issues
[4]: http://www.musl-libc.org
[5]: http://www.etalabs.net/compare_libcs.html
[6]: https://news.ycombinator.com/item?id=10782897
[10]: https://en.wikipedia.org/wiki/Dovecot_(software)
[91]: https://github.com/instrumentisto/dovecot-docker-image/blob/master/LICENSE.md
[92]: https://www.dovecot.org/doc/COPYING
[93]: https://www.dovecot.org/doc/COPYING.LGPL
[94]: https://www.dovecot.org/doc/COPYING.MIT
[101]: https://github.com/instrumentisto/dovecot-docker-image/blob/master/debian/Dockerfile
[102]: https://github.com/instrumentisto/dovecot-docker-image/blob/master/alpine/Dockerfile
