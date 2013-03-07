namespace eval Docopt {
    oo::class create Pattern {

    }

    oo::class create ChildPattern {
        superclass Pattern
    }

    oo::class create ParentPattern {
        superclass Pattern
    }

    oo::class create Argument {
        superclass ChildPattern
    }

    oo::class create Command {
        superclass Argument
    }

    oo::class create Option {
        superclass ChildPattern

        self method parse { option_description } {
            set short {}
            set long {}
            set argcount 0
            set value {}

            regexp -indices -- "  " [string trim $option_description] pos

            set options [string range $option_description 0 [lindex $pos 0]-1]
            set description [string range $option_description [lindex $pos 1]+1 "end"]

            foreach s [split $options "=, "] {
                if { [string range $s 0 1] == "--" } {
                    set long $s
                } elseif { [string range $s 0 0] == "-" }  {
                    set short $s
                } else {
                    set argcount 1
                }
            }

            if { $argcount > 0 } {
                set matched [regexp -inline -all -nocase -- {\[default: (.*)\]} $description]
                if { [llength $matched] > 0 } {
                    set value [lindex $matched 1]
                }
            }

            my new $short $long $argcount $value
        }

        constructor { short long argcount value } {
            set [self]::short $short
            set [self]::long $long
            set [self]::argcount $argcount
            set [self]::value $value
        }
    }

    oo::class create Required {
        superclass ParentPattern
    }

    oo::class create Optional {
        superclass ParentPattern
    }

    oo::class create AnyOptions {
        superclass Optional
    }

    oo::class create OneOrMore {
        superclass ParentPattern
    }

    oo::class create Either {
        superclass ParentPattern
    }

    oo::class create TokenStream {

    }

    # long ::= '--' chars [ ( ' ' | '=' ) chars ] ;
    proc parse_long { tokens options } {

    }

    proc parse_defaults { doc } {
        set matches [regexp -all -inline {\n *(<\S+?>|-\S+?)} $doc]

        set options [list]

        foreach {s1 s2} $matches {
            set str "$s1$s2"
            if { [string range $str 0 1] == "-" } {
                lappend options [Option parse $str]
            }
        }

        return $options
    }

    proc printable_usage { doc } {
        set matches [regexp -all -nocase -indices -inline "usage:" $doc]

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

    proc docopt { doc { argv {} } { help true } { version {} } { options_first false } } {

    }
}