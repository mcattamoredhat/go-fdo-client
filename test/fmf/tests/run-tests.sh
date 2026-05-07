#!/bin/bash
# Runner wrapper for manual / brew-build testing.
#
# Installs the go-fdo-client package (from a brew URL, a local RPM, or the
# fedora-iot COPR) and the go-fdo-server packages (always from COPR), then
# runs the requested test suite.
#
# Usage:
#   # Install both client and server from brew/koji RPM URLs
#   sudo BREW_CLIENT_URL=<client-url> \
#        BREW_SERVER_URL=<server-url> \
#        ./test/fmf/tests/run-tests.sh onboarding
#
#   # Client from brew, server from COPR (default for server)
#   sudo BREW_CLIENT_URL=<client-url> ./test/fmf/tests/run-tests.sh onboarding
#
#   # Client from a local RPM file, server from COPR
#   sudo CLIENT_RPM_PATH=/path/to/go-fdo-client-*.rpm ./test/fmf/tests/run-tests.sh onboarding
#
#   # Both from COPR (default behaviour, equivalent to a full tmt run)
#   sudo ./test/fmf/tests/run-tests.sh onboarding
#
#
# Available tests:
#   onboarding   - Full DI → voucher transfer → TO0 → TO1+TO2 onboarding
#   retry-loop   - RV bypass, directive delays, SIGINT, TO2 retry delay (3 scenarios)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

TEST_NAME="${1:-onboarding}"

log_info "=== Installing go-fdo-client ==="
install_client

log_info "=== Installing go-fdo-server ==="
install_server

log_info "=== Resetting FDO server databases ==="
reset_fdo_databases

log_info "=== Running test: ${TEST_NAME} ==="
case "${TEST_NAME}" in
    onboarding)
        exec "${SCRIPT_DIR}/test-onboarding.sh"
        ;;
    retry-loop)
        exec "${SCRIPT_DIR}/test-retry-loop.sh"
        ;;
    *)
        log_error "Unknown test '${TEST_NAME}'. Valid options: onboarding, retry-loop"
        exit 1
        ;;
esac
