# List all the recipes.'
_list-recipes:
    @just --list

# Count the SLOCs in the project
slocs:
    tokei ./ ./math/

# Run all the tests in the project
test:
    odin test math -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning
    odin test . -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning

# Run the single specified test (<package name>.<test name>)
test_one name:
    odin test . -vet -define:ODIN_TEST_NAMES={{name}}

# Clean up the project
clean:
    rm -rf *.exe
    rm -rf *.pdb
