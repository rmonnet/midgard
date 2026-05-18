# List all the recipes.'
_list-recipes:
    just --list

# Count the SLOCs in the project
slocs:
    tokei ./ ./math/

# Test all files in the project
test:
    odin test math -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning
    odin test . -vet -define:ODIN_TEST_SHORT_LOGS=true -define:ODIN_TEST_LOG_LEVEL=warning

# Clean up the project
clean:
    rm -rf *.exe
    rm -rf *.pdb
