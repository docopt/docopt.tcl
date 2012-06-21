namespace eval Docopt {
    proc docopt { doc args } {

        if { [llength $args] > 3 } {
            error "too many args"
        }

        set version [expr { [llength $args] == 3 ? [lindex $args 2] : "" }]
        set help    [expr { [llength $args] == 2 ? [lindex $args 1] : false }]
        set args    [expr { [llength $args] == 1 ? [lindex $args 0] : $::argv }]

        return ""
    }

    proc printable_usage { doc } {
        set matches [regexp -all -nocase -indices -inline {usage:} $doc]

        if { [llength $matches] == 0 } {
            return -code error -errorcode "DocoptLanguageError" "\"usage:\" (case-insensitive) not found."
        }

        if { [llength $matches] > 1 } {
            return -code error -errorcode "DocoptLanguageError" "More than one \"usage:\" (case-insensitive)."
        }

        set usage [string range $doc [lindex $matches 0 0] end]

        if { [regexp -indices {\n\s*\n} $usage usage_end] } {
            return [string range $usage 0 [lindex $usage_end 0]-1]
        }

        return $usage
    }

    proc formal_usage { printable_usage } {
        set pu [split [string range $printable_usage 7 end]]; # split and drop usage

        set result [list]
        foreach s [lrange $pu 1 end] {
            if { $s == [lindex $pu 0] } {
                lappend result "|"
            } elseif { $s != "" } {
                lappend result $s
            }
        }

        join $result " "
    }

    proc parse_doc_options { doc } {
        set result ""

        foreach line [split $doc "\n"] {
            if { [regexp {^ *-} $line] } {
                lappend result [Option::parse $line]
            }
        }

        return $result
    }

    namespace eval Option {
        proc parse { description } {
            set result [dict create "argcount" "0"]

            set description [string trim $description]

            if { [set seperator [string first "  " $description]] > -1 } {
                set options [string range $description 0 $seperator]
                set description [string range $description $seperator+2 end]
            } else {
                set options $description
                set description ""
            }

            set options [string map {"=" " " "," " "} $options]

            foreach option $options {
                if { [string range $option 0 1] == "--" } {
                    dict set result "long" $option
                } elseif { [string range $option 0 0] == "-" } {
                    dict set result "short" $option
                } else {
                    dict set result "argcount" 1
                }
            }

            if { [regexp -nocase {\[default: (.*)\]} $description -> default] } {
                dict set result "default" $default
            }

            if { [dict exists $result "long"] || [dict exists $result "short"] } {
                return $result
            } else {
                return ""
            }
        }
    }
}
