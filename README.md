# Network Connection

This package helps you keep track of whether the user's browser is connected
to the internet. It will allow you to manage activity that should only be
performed when a connection is available and resume and resynchronize once the
connection resumes.

This package is backed by the [`navigator.onLine` and `online`/`offline` events](https://developer.mozilla.org/en-US/docs/Online_and_offline_events).
