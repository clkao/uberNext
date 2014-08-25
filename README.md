uberNext
======

[Install on chrome web store](https://chrome.google.com/webstore/detail/jjfmdmihlopbdahppjepejbjjphjfdca)

Chrome extension for getting notification when Uber becomes available.

# Install

    % npm i
    % npm run build

then load use Chrome extension manager to load dist/.

# Development

You need get an [Uber API Key](https://developer.uber.com/).  You'll also need
to run a local [oauthd](https://github.com/clkao/oauthd/tree/uber-provider)
with the uber provider branch.  Configure your oauthd app with Uber keys, and
update `src/popup.ls` with the oauthd public key. Make sure you add your local
chrome extension url to the "Domains available" option in oauthd app:
`chrome-extension://longstringlongstring`

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to twlyparser.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
