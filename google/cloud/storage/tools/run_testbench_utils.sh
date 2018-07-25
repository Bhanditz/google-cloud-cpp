#!/usr/bin/env bash
#
# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "${PROJECT_ROOT+x}" ]; then
  readonly PROJECT_ROOT="$(cd "$(dirname $0)/../../../.."; pwd)"
fi
source "${PROJECT_ROOT}/ci/colors.sh"

TESTBENCH_PID=0
TESTBENCH_DUMP_LOG=yes

################################################
# Terminate the Google Cloud Storage test bench
# Globals:
#   TESTBENCH_PID: the process id for the test bench
#   TESTBENCH_DUMP_LOG: if set to 'yes' the testbench log is dumped
#   SHUTDOWN_ENDPOINT: sending a http POST to this endpoint shuts down
#                      the test bench
#   COLOR_*: colorize output messages, defined in colors.sh
# Arguments:
#   None
# Returns:
#   None
################################################
kill_testbench() {
  echo "${COLOR_GREEN}[ -------- ]${COLOR_RESET} Integration test environment tear-down."
  echo -n "Killing testbench server [${TESTBENCH_PID}] ... "
  curl -d "please shutdown" "${SHUTDOWN_ENDPOINT}"
  wait >/dev/null 2>&1
  echo "done."
  if [ "${TESTBENCH_DUMP_LOG}" = "yes" ]; then
    echo "================ [begin testbench.log] ================"
    cat "testbench.log"
    echo "================ [end testbench.log] ================"
  fi
  echo "${COLOR_GREEN}[ ======== ]${COLOR_RESET} Integration test environment tear-down."

}

################################################
# Start the Google Cloud Storage test bench
# Globals:
#   TESTBENCH_PORT: the listening port for the test bench, 8000 if not set.
#   HTTPBIN_ENDPOINT: the httpbin endpoint on the test bench.
#   TESTBENCH_PID: the process id for the test bench.
#   SHUTDOWN_ENDPOINT: posting to this endpoint will shut down the test bench.
#   CLOUD_STORAGE_TESTBENCH_ENDPOINT: the google cloud storage endpoint for the
#       test bench.
#   COLOR_*: colorize output messages, defined in colors.sh
# Arguments:
#   None
# Returns:
#   None
################################################
start_testbench() {
  echo "${COLOR_GREEN}[ -------- ]${COLOR_RESET} Integration test environment set-up"
  echo "Launching testbench emulator in the background"
  trap kill_testbench EXIT

  # The tests typically run in a Docker container, where the ports are largely
  # free; when using in manual tests, you can set EMULATOR_PORT.
  readonly PORT=${TESTBENCH_PORT:-8000}

  "${PROJECT_ROOT}/google/cloud/storage/tests/testbench.py" --port ${PORT} \
      >testbench.log 2>&1 </dev/null &
  TESTBENCH_PID=$!

  export HTTPBIN_ENDPOINT="http://localhost:${PORT}/httpbin"
  export SHUTDOWN_ENDPOINT="http://localhost:${PORT}/shutdown"
  export CLOUD_STORAGE_TESTBENCH_ENDPOINT="http://localhost:${PORT}"

  delay=1
  connected=no
  readonly ATTEMPTS=$(seq 1 8)
  for attempt in $ATTEMPTS; do
    if curl "${HTTPBIN_ENDPOINT}/get" >/dev/null 2>&1; then
      connected=yes
      break
    fi
    sleep $delay
    delay=$((delay * 2))
  done

  if [ "${connected}" = "no" ]; then
    echo "Cannot connect to testbench; aborting test." >&2
    exit 1
  else
    echo "Successfully connected to testbench [${TESTBENCH_PID}]"
  fi

  echo "${COLOR_GREEN}[ ======== ]${COLOR_RESET} Integration test environment set-up."
}
