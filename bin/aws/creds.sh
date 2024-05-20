#!/bin/bash

set -eou nounset

if ! env | grep OP_SESSION_ > /dev/null; then
    eval $(op signin)
fi

eval $(pmv env aws/mend-io)
