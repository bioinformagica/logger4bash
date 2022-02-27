#!/usr/bin/env bash

setup () {

    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"

}


@test 'print only expected level' {
    run test.sh
}
