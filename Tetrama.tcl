package require tetrama 2.0
package require Tclx

set retcode 0

proc showHelp {} {
	puts "Tetrama"
	puts "usage: Tetrama \[options\] source \[target\]"
	puts "if target is not set then source is target"
}

set doTest 0

switch [lindex $argv 0] {
     "/?" { 
          showHelp
          exit 
     }
     "/h" { 
          showHelp
          exit 
     }
     "-h" { 
          showHelp
          exit 
     }
     "--help" { 
          showHelp
          exit 
     }
     "--testerr" { 
          set retcode -1
          exit
     }
     "--test" { 
          lvarpop argv
          set doTest 1
          set evalString {set retcode [Test [lindex $argv 0] [lindex $argv 1]]}}
     "default" { 
          set evalString {set retcode [Tetrama {*}$argv] }
     }
}

set source [lindex $argv 0]
if {[llength $argv] == 2} {
	set target [lindex $argv 1]	
} else {
	set target $source
}

if {[regexp {\*} $source all] != 0} {
     set sourcelist [glob $source]
     if {[llength $sourcelist] > 0} {
          regsub {\*} $source {(.+)} source

          foreach sourcefile $sourcelist {
               if {[llength $argv] == 2} {
                    regexp $source $sourcefile one two
                    regsub {\*} $target $two nexttarget
                    if {$doTest} {
                         set retcode [Test $sourcefile $nexttarget]
                    } else {
                         set retcode [Tetrama $sourcefile $nexttarget]
                    }
               } else {
                    if {$doTest} {
                         set retcode [Test $sourcefile $sourcefile]
                    } else {
                         set retcode [Tetrama $sourcefile $sourcefile]
                    }
               }
          }
     }
} else {
     eval $evalString
}

if {$retcode != 0} {
     puts "NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
}
