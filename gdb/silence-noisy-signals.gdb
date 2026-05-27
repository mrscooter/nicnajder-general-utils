# Silence signals that multithreaded C++ apps generate constantly.
# nostop: don't pause; noprint: don't mention; pass: still deliver to the app.

handle SIGPIPE nostop noprint pass
handle SIGUSR1 nostop noprint pass
handle SIGUSR2 nostop noprint pass
handle SIG32   nostop noprint pass
handle SIG33   nostop noprint pass
handle SIG34   nostop noprint pass
