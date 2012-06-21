Spec require "lib/docopt.tcl"

describe "::Docopt" {
    describe "::docopt" {
        it "allows empty patterns" {
            expect [Docopt::docopt "Usage: prog"] to equal {}
        }
    }

    describe "::parse_doc_options" {
        it "returns a list of parsed options from the docstring" {
            set options [Docopt::parse_doc_options "
-h, --help  Print help message.
-o FILE     Output file.
--verbose   Verbose mode."]

            expect [dict get [lindex $options 0] "short"] to equal "-h"
            expect [dict get [lindex $options 0] "long"] to equal "--help"
            expect [dict get [lindex $options 0] "argcount"] to equal 0

            expect [dict get [lindex $options 1] "short"] to equal "-o"
            expect [dict get [lindex $options 1] "argcount"] to equal 1

            expect [dict get [lindex $options 2] "long"] to equal "--verbose"
            expect [dict get [lindex $options 2] "argcount"] to equal 0
        }
    }

    describe "::printable_usage" {
        it "returns the printable usage string" {
            expect [Docopt::printable_usage "
Usage: prog \[-hv] ARG
       prog N M

prog is some program."] to equal "Usage: prog \[-hv] ARG\n       prog N M"

            expect [
                Docopt::printable_usage "uSaGe: prog ARG\n\t \t\n bla"
            ] to equal "uSaGe: prog ARG"
        }
    }

    describe "::formal_usage" {
        it "returns a condensed usage string from a printable usage string" {
            expect [
                Docopt::formal_usage "Usage: prog \[-hv] ARG\n       prog N M"
            ] to equal "\[-hv] ARG | N M"
        }
    }

    describe "::Option" {
        describe "::parse" {
            it "correctly parses short options" {
                set result [Docopt::Option::parse "-h"]

                expect [dict get $result "argcount"] to equal 0
                expect [dict get $result "short"] to equal "-h"
                expect [dict exists $result "long"] to be false
            }

            it "correctly parses an indented option" {
                set result [Docopt::Option::parse "    -h"]

                expect [dict get $result "argcount"] to equal 0
                expect [dict get $result "short"] to equal "-h"
                expect [dict exists $result "long"] to be false
            }

            it "correctly parses long options" {
                set result [Docopt::Option::parse "--help"]

                expect [dict get $result "argcount"] to equal 0
                expect [dict get $result "long"] to equal "--help"
                expect [dict exists $result "short"] to be false
            }

            it "correctly parses short and long options" {
                set result [Docopt::Option::parse "-h --help"]

                expect [dict get $result "argcount"] to equal 0
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"

                set result [Docopt::Option::parse "-h, --help"]

                expect [dict get $result "argcount"] to equal 0
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"
            }

            it "correctly parses short options with an argument" {
                set result [Docopt::Option::parse "-h TOPIC"]

                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "short"] to equal "-h"
                expect [dict exists $result "long"] to be false
            }

            it "correctly parses long options with an argument" {
                set result [Docopt::Option::parse "--help TOPIC"]

                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "long"] to equal "--help"
                expect [dict exists $result "short"] to be false
            }

            it "correctly parses long and short options with an argument" {
                set result [Docopt::Option::parse "-h TOPIC --help TOPIC"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"

                set result [Docopt::Option::parse "-h TOPIC, --help TOPIC"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"

                set result [Docopt::Option::parse "-h TOPIC --help=TOPIC"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"

                set result [Docopt::Option::parse "-h TOPIC, --help=TOPIC"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "long"] to equal "--help"
                expect [dict get $result "short"] to equal "-h"
            }

            it "correctly parses arguments with default values" {
                set result [Docopt::Option::parse "-h TOPIC  Description... \[default: 2]"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "default"] to equal "2"
                expect [dict get $result "short"] to equal "-h"
                expect [dict exist $result "long"] to be false

                set result [Docopt::Option::parse "-h TOPIC  Description... \[default: topic-1]"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "default"] to equal "topic-1"
                expect [dict get $result "short"] to equal "-h"
                expect [dict exist $result "long"] to be false

                set result [Docopt::Option::parse "-h TOPIC  Description... \[default: 3.14]"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "default"] to equal "3.14"
                expect [dict get $result "short"] to equal "-h"
                expect [dict exist $result "long"] to be false

                set result [Docopt::Option::parse "-h, --help=DIR  ... \[default: ./]"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "default"] to equal "./"
                expect [dict get $result "short"] to equal "-h"
                expect [dict get $result "long"] to equal "--help"

                set result [Docopt::Option::parse "-h TOPIC  Description... \[dEfAuLt: 2]"]
                expect [dict get $result "argcount"] to equal 1
                expect [dict get $result "default"] to equal "2"
                expect [dict get $result "short"] to equal "-h"
                expect [dict exist $result "long"] to be false
            }
        }
    }
}
