Squid - Have We Met?
=====================

This is a Squid-based Proof of Concept implementation of a security proxy that requires user confirmation if a destination service was never encountered before by the proxy.

This concept was mentioned at least at the following places (if you know of more, please open an Issue or PR!):
* https://www.slideshare.net/FlorianRoth2/ransomware-resistance

Since I couldn't find an open-source implementation, I created one. This implementation allows experimentation with the concept but it is in no way meant for production use!


Goals
-----

The primary goal of this tool is to make phishing attempts more visible to users.

It can _accidentaly_ also disrupt automated C2 to unknown domains (but not to high-reputation ones, see for example OneDrive-based channels), but since in essence all data to confirm a domain is made available to the proxy client by design, this would turn the problem into an automated Turing-test. Integrating CAPTCHA's in a user-friendly way is an interesting challenge, but it is out-of-scope for this implementation.  


Usage
-----

### Debian

- Extract files under `/opt/havewemet` and provide execute access to the proxy user on the `havewemet` script!
- Copy `havewemet.conf` to `/etc/squid/conf.d/`!
- Copy `havewemet.html` to `/usr/share/squid/errors/templates` (Documentation is a lie, absolute paths don't work :P). This page definitely needs some better security UX, PR's are welcome!
- Restart Squid!


How Does It Work?
-----------------

We have a database of known network locations (netlocs - hostname + port, from Python's `urllib`).

If a request's netloc is not in the database, we display an error page that includes a dynamically generated link to the original URL (no JavaScript, yay!), extended with a unique, random generated token, that we keep track of in the DB too. (This of course only works for user-initiated GET requests.)

The check is implemented in an external ACL script referenced by Squid. Squid passes the request URL to the script, and the script answers with a pass/fail result, that can also include a message - this message contains the dynamic URL with the confirmation token, that is inserted to the error page displayed for the user. 

The netloc is inserted to the database if a request with a known token in an appropriately named URL parameter is encountered. 


Known issues
------------

* Modern websites are rarely served from a single domain. It is a TODO to handle browser sessions to multiple backend domains transparently.
* This won't work if some malware expects the splash page and extracts the verification token. This is outside of our threat model.
* Tokens and netlocs are not connected. I couldn't see a plausible attack vector for this, if you find one, please use the Issue tracker!
* Duplicate GET parameters in the original request are probably not handled properly.


TODO
----

* Handle background dependencies of websites transparently (CDN's, backend API's, YouTube's anti-adblock content domains, etc.)
* Implement for saner open-source proxies
* Performance benchmarks, optimization
* Other DB backends?


Security
--------

While it is already established that *there is no warranty* for this software and it should not be used in production, I'm still interested in any security issues you can find. Feel free to use the Issue tracker to file a bug!


