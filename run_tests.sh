#!/bin/bash

set +e
bash tests/test_list.sh
bash tests/test_start.sh
bash tests/test_refresh.sh
set -e
