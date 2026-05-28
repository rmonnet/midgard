package alambic

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {

	fmt.println("Welcome to alambic!")

	if len(os.args) != 3 {
		fmt.eprintf("Usage: alambic <odin source file> <markdown file>")
		os.exit(1)
	}
	srcfile := os.args[1]
	outfile := os.args[2]
	fmt.printf("Processing %s => %s\n", srcfile, outfile)

	source, src_err := os.read_entire_file(srcfile, context.allocator)
	if src_err != nil {
		fmt.eprintf("Unable to read %s: %v\n", srcfile, src_err)
		os.exit(1)
	}

	out, out_err := os.open(outfile, {.Create, .Write})
	if out_err != nil {
		fmt.eprintf("Unable to open %s for writing: %v\n", outfile, out_err)
		os.exit(1)
	}
	defer os.close(out)

	lines := strings.split_lines(string(source))

	location: Location
	markdown := true

	for line in lines {
		switch location {
		case .Preamble:
			// Ignore Code and Multi-Line Comment blocks in the Preamble section.
			if strings.starts_with(line, "/*") {location = .Code}
		case .Code:
			// That section can contain Multi-Line Comments or Code blocks.
			// We assume the Code section always starts with a Multi-Line comment.
			if strings.starts_with(line, "*/") {
				markdown = false
				fmt.fprintln(out, "```odin")
				continue
			} else if strings.starts_with(line, "/*") {
				markdown = true
				fmt.fprintln(out, "```")
				continue
			} else if strings.starts_with(line, "// Tests") {
				location = .Tests
				continue
			}
			// if markdown {
			// 	fmt.printf("M>%s\n", line)
			// } else {
			// 	fmt.printf("C>%s\n", line)
			// }
			fmt.fprintln(out, line)
		case .Tests:
		// Ignore everything in this section.
		}
	}
}

Location :: enum {
	Preamble,
	Code,
	Tests,
}

