#!/usr/bin/env bash
# Test midgard and all sub-libraries.

odin test math -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning
odin test . -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning
