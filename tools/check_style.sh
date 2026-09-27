#!/bin/bash

# Copyright 2013-present Barefoot Networks, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Antonin Bas (antonin@barefootnetworks.com)

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

ROOT_DIR=$THIS_DIR/..

return_status=0

# used for C files
function run_clang_format() {
    # $1 is directory
    find $1 -name '*.h' -o -name '*.c' | xargs -r $THIS_DIR/clang_format_check.py -s file
    return_status=$(($return_status || $?))
}

# used for C++ files
function run_cpplint() {
    # $1 is directory
    # $2 is root (for include guard)
    python3 $THIS_DIR/cpplint.py --repository=$ROOT_DIR --root=$2 $( find $1 -name \*.h -or -name \*.cpp )
    return_status=$(($return_status || $?))
}

run_clang_format $ROOT_DIR/src
run_clang_format $ROOT_DIR/include
run_clang_format $ROOT_DIR/targets/rpc
run_clang_format $ROOT_DIR/targets/dummy
run_clang_format $ROOT_DIR/CLI
run_clang_format $ROOT_DIR/tests
run_clang_format $ROOT_DIR/generators
run_clang_format $ROOT_DIR/examples
run_clang_format $ROOT_DIR/bin
run_clang_format $ROOT_DIR/lib

run_cpplint $ROOT_DIR/targets/bmv2
run_cpplint $ROOT_DIR/frontends_extra/cpp frontends_extra/cpp
run_cpplint $ROOT_DIR/proto/p4info
run_cpplint $ROOT_DIR/proto/frontend proto/frontend
run_cpplint $ROOT_DIR/proto/tests
run_cpplint $ROOT_DIR/proto/src
run_cpplint $ROOT_DIR/proto/PI proto
run_cpplint $ROOT_DIR/proto/server

echo "********************************"
if [ $return_status -eq 0 ]; then
    echo "STYLE CHECK SUCCESS"
else
    echo "STYLE CHECK FAILURE"
fi

exit $return_status
