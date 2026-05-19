# List all the recipes.'
_list-recipes:
    @just --list

# Count the SLOCs in the project
slocs:
    tokei ./ ./math/

# Run all the tests in the project
test:
    -odin test math -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning
    -odin test . -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning

# Run the single specified test (<package name>.<test name>)
test-single name:
    odin test . -vet -define:ODIN_TEST_NAMES={{ name }}

# Provides system information
system-info:
    @echo "Odin    : {{ trim_start_match(`odin version`, 'odin ') }}"
    @echo "CPU Arch: {{ arch() }}"
    @echo "# cores : {{ num_cpus() }}"
    @echo "OS      : {{ os() }}"

# Clean up the project
clean:
    rm -rf *.exe
    rm -rf *.pdb

# Look for commented-out tests
disabled-tests:
    -@grep -n '//@(test)' *.odin
    -@grep -n '//@(test)' */*.odin
