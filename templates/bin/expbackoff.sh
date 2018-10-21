#!/usr/bin/env bash

expbackoff() {
    # Exponential backoff: retries a command upon failure, scaling up the delay between retries.
    # Example: "expbackoff my_command --with --some --args --maybe"
    local max_retries=${EXPBACKOFF_MAX_RETRIES:-8} # Max number of retries
    local base=${EXPBACKOFF_BASE:-1} # Base value for backoff calculation
    local max=${EXPBACKOFF_MAX:-300} # Max value for backoff calculation
    local failures=0
    while ! "$@"; do
        failures=$(( failures + 1 ))
        if (( failures > max_retries )); then
            echo "$@" >&2
            echo " * Failed, max retries exceeded" >&2
            return 1
        else
            local seconds=$(( base * 2 ** (failures - 1) ))
            if (( seconds > max )); then
                seconds=$max
            fi
            echo "$@" >&2
            echo " * $failures failure(s), retrying in $seconds second(s)" >&2
            sleep "$seconds"
            echo
        fi
    done
}

# something_that_succeeds() { echo "I'm a winner!"; }
# something_that_fails() { echo "I'm a loser :("; return 1; }

# EXPBACKOFF_MAX_RETRIES=3 # Override default value - speeds up testing
# expbackoff something_that_succeeds --calling it with -args
# echo # Clear up the display
# expbackoff something_that_fails --calling it with -args
# echo
# echo $? # Should be 1, indicating overall failure of `something_that_fails`
