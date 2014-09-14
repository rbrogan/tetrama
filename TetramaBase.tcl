package provide tetrama 3.0
package require sqlite3
package require gen

array set R {}

namespace eval TetramaNS {

set DoBackup 1
set Force 1
set DebugOn 0

proc Debug {Message} {
     variable DebugOn
     
     if {$DebugOn} {
          puts $Message
     }
}

proc Tetrama {InFileName OutFileName args} {
     Debug "Tetrama: $InFileName $OutFileName $args"

     global R
     global PhiareC
     
     array unset PhiareC

     # Make backup
     # If the backup already exists and the input file has not changed, 
     # then skip making another.
     if {[file exists $OutFileName]} {
          set BackupFileName "[set OutFileName].bak"
          # Check to see if backup file exists
          if {[file exists $BackupFileName]} {
               array set MyArray {}
               file stat $InFileName MyArray
               set InMTime $MyArray(mtime)
               file stat $BackupFileName MyArray
               set BackupMTime $MyArray(mtime)
               
               # Check to see if backup file has newer mtime than input.
               # If so then skip this run and return, unless Force flag is set.
               if {([expr $BackupMTime > $InMTime]) && !$TetramaNS::Force} {
                    Debug "Input not modified since last backup made. Skipping this."
                    return -1
               }
          }
          
          # Backup the output file
          Debug "Making backup: $BackupFileName"
          CopyFile $OutFileName $BackupFileName
     }
         
     # Read the (Unicode) input file into a list and then close the file.
     Debug "Reading input: $InFileName"
     set R(FP) [open $InFileName r]
     fconfigure $R(FP) -encoding utf-8
     set FileData [read -nonewline $R(FP)]
     close $R(FP)
     
     # Open the (Unicode) output file for writing
     Debug "Reading output: $OutFileName"
     set R(FP) [open $OutFileName w+]
     fconfigure $R(FP) -encoding utf-8
     set R(Data) [split $FileData "\n"]
     set R(LineCount) [llength $R(Data)]
     set R(OutputFlag) 1
     set R(Debug) 0
     set R(Flag) 1
     
     # Iterate over each line in the input data using a counter.
     Debug "Main loop begin"
     for {set R(Counter) 0} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          # Keep the current line in a variable
          set R(CurrentLine) [lindex $R(Data) $R(Counter)]          
          Debug "1 | $R(CurrentLine)"
          
          # Do any replacements on the line.
          set R(CurrentLine) [DoReplacements $R(CurrentLine)]
          Debug "2 | $R(CurrentLine)"
          
          # Assay for directive.
          set Directive [AssayForDirective $R(CurrentLine)]
          if {$Directive != 0} {
               Debug "Got directive: $Directive"
          }
          
          # Run pre-directive, if any.
          if {($Directive != 0) && [string equal $R(DirectiveType) pre]} {
               Debug "Running pre-directive"
               uplevel #0 $Directive
          }
          
          # Output the line.
          if {$R(Flag) && $R(OutputFlag)} {
               Debug "Copying line to output"
               puts $R(FP) $R(CurrentLine)
          } else {
               Debug "Output is suppressed"
          }
          
          # Run post-directive, if any.
          if {($Directive != 0) && [string equal $R(DirectiveType) post]} {
               Debug "Running post-directive"
               uplevel #0 $Directive
          }
          
          set R(OutputFlag) 1
     }
     
     Debug "Main loop end"
     Debug "Flushing and closing output"
     
     flush $R(FP)
     close $R(FP)
     
     Debug "Tetrama: DONE"
     
     return 0
}

proc Test {InFileName OutFileName} {
     global errorInfo
     
     Debug "TESTING"
     
     # Run the program.
     if {[catch {Tetrama $InFileName $OutFileName} ReturnCode]} {
          puts "Error running program. Caught exception."
          puts $errorInfo
          return -1
     }

     if {$ReturnCode != 0} {
          puts "Error in ReturnCode: $ReturnCode"
          return $ReturnCode
     }
     
     set Expected "[set OutFileName].exp"
     Debug "Will exec: diff $OutFileName $Expected"
     set ReturnCode [catch {exec diff $OutFileName $Expected} Output]
     if {$ReturnCode == 0} {
          puts "No difference."
     } else {
          if {[string equal [lindex $::errorCode 0] CHILDSTATUS]} {
               if {[lindex $::errorCode 2] == 1} {
                    puts "Difference"
                    puts [string replace $Output end-31 end ""]
               } else {
                    puts "Diff error: $Output"
               }
          } else {
               puts "Error calling diff: $Output"
          }
     }
     
     if {$ReturnCode == 0} {
          puts "passed"
     } else {
          puts "failed"
     }
     
     return $ReturnCode
}

proc DoReplacements {Line} {
     global PhiareC
     global PhiareK

     # Search for special symbol that says not to do replacements.
     if {[string first "\u266A" $Line] != -1} {
          Debug "Not doing replacements on line $Line"
          return $Line
     }
     
     # Iterate over the keys,
     # try to find them in the current line,
     # and if found, then substitute in the value.
     foreach Key [array names PhiareK] {
          Debug "Trying to find $Key"
          set NumMatches [regsub -all $Key $Line $PhiareK($Key) Line]
          if {$NumMatches > 0} {
               Debug "Found $Key, replaced with $PhiareK($Key)"
               Debug "  | $Line"
          }
     }
     
     foreach Key [array names PhiareC] {
          Debug "Trying to find $Key"     
          set NumMatches [regsub -all $Key $Line $PhiareC($Key) Line]
          if {$NumMatches > 0} {
               Debug "Found $Key, replaced with $PhiareC($Key)"
               Debug "  | $Line"
          }          
     }
     
     # Find and run all embedded commands
     set Done 0
     while {$Done == 0} {
          set Done 1
          if {[regexp {(\s*)\uff3b([^\uff3b]*)\uff3d} $Line All Whitespace Code] == 1} {
               set R(Whitespace) $Whitespace
               
               Debug "Found embedded command: $Code"
               # Run the command at global scope and substitute it in.
               set ReturnValue [uplevel #0 $Code]
               Debug "Ran it and got return value $ReturnValue"
               regsub {\uff3b([^\uff3b]*)\uff3d} $Line $ReturnValue Line
               Debug "  | $Line"
               set Done 0
          }
     }
     
     return $Line
}

proc AddPhiare {Arg1 Arg2 {Arg3 0}} {
     if {[string equal $Arg1 -c]} {
          global PhiareC
          set PhiareC($Arg2) $Arg3
          Debug "Added Clearing Phiare $Arg2 -> $Arg3"
     } elseif {[string equal $Arg1 -k]} {
          global PhiareK
          set PhiareK($Arg2) $Arg3
          Debug "Added Keeping Phiare $Arg2 -> $Arg3"
     } else {
          global PhiareK
          set PhiareK($Arg1) $Arg2
          Debug "Added Keeping Phiare $Arg1 -> $Arg2"
     }
}

proc AssayForDirective {Line} {
     global R
     
     Debug "Assaying for directive"
     if {[regexp {\u00a7\s(.+)\s\u00a7} $Line All Directive] == 1} {
          # Post-directive, copy to output.
          Debug "Got post-directive"
          set R(DirectiveType) post
          return $Directive
     } elseif {[regexp {\u00b6\s(.+)\s*\u00B6*} $Line All Directive] == 1} {
          # Pre-directive, copy to output.
          Debug "Got pre-directive"
          set R(DirectiveType pre
          return $Directive
     } elseif {[regexp {\u203c\s(.+)} $Line All Directive] == 1} {
          # Post-directive, do not copy to output.
          Debug "Got post-directive with output suppression"
          set R(DirectiveType) post
          set R(OutputFlag) 0
          return $Directive
     } else {
          return 0
     }
}

proc PutSection {args} {
     global R
     
     set Argument [join $args " "]
     
     # Open the file for writing
     set OutFilePath [open $OutFilePath w+]
     fconfigure $OutFilePath -encoding utf-8
     for {incr R(Counter)} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          set R(CurrentLine) [lindex $R(Data) $R(Counter)]
          
          # Output the line to output file as-is.
          puts $R(FP) $R(CurrentLine)
          
          # Do any replacements on the line.
          set R(CurrentLine) [DoReplacements $R(CurrentLine)]
          
          # Check for EOS. If so, exit loop. If not write line to file.
          if {[string match "#endif" $R(CurrentLine)]} {
               break
          } else {
               puts $OutFilePath $R(CurrentLine)
          }
     }
     
     # Flush and close the file
     flush $OutFilePath
     close $OutFilePath
}

proc PutSection2 {args} {
     global R
     
     set Argument [join $args " "]
     
     if {[regexp {TABLE=\((.+)\) SET=\((.+)\) WHERE=\((.+)\)} $Argument All TableName Set Where] == 0} {
          puts "PutSection2: Input malformed -- $Argument"
          return -1
     }
     
     set AttributeValueList [CommaSeparatedStringToList $Set]
     set SetDict [dict create]
     foreach Element $AttributeValueList {
          MultiSet {Key Value} [split Element =]
          dict set SetDict $Key $Value
     }

     set AttributeValueList [CommaSeparatedStringToList $Where]
     set WhereDict [dict create]
     foreach Element $AttributeValueList {
          MultiSet {Key Value} [split Element =]
          dict set WhereDict $Key $Value
     }
     
     set Data ""
     
     # Iterate over the lines, perform replacements, append to output.
     # Stop on hitting EOS.
     for {incr R(Counter)} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          set R(CurrentLine) [lindex $R(Data) $R(Counter)]
          
          # Output the line to output file as-is.
          puts $R(FP) $R(CurrentLine)
          
          # Do any replacements on the line.
          set R(CurrentLine) [DoReplacements $R(CurrentLine)]
          
          # Check for EOS. If so, exit loop. If not, append to output.
          if {[string match "#endif" $R(CurrentLine)]} {
               break
          } else {
               append Data "$R(CurrentLine)\n"
          }
     }
     
     InsertOrOverwrite2 $TableName $WhereDict $SetDict
}

proc Subsection {} {
     global R
     
     if {[regexp "Subsection (.+) Begin" $R(CurrentLine) All Subsection]} {
          if {[info exists $R($Subsection)]} {
               puts $R(FP) $R($Subsection)
               unset R($Subsection)
          }
     }
}

proc PullSection {args} {
     global R
     global PhiareC
     global PhiareK
     
     set SourceFilePath [join $args " "]
     set SavedCounter $R(Counter)
     
     # Open the file for reading.
     Debug "Opening $SourceFilePath for pull"
     set SourceFilePointer [open $SourceFilePath r]
     fconfigure $SourceFilePointer -encoding utf-8
     set FileData [read $SourceFilePointer]
     close $SourceFilePointer
     
     set SectionHeader "// \u00a7> $SourceFilePath <\u00a7"
     set SectionFooter "// \u00a7< $SourceFilePath >\u00a7"
     
     Debug "Scanning for subsections"
     set State 0
     for {incr R(Counter)} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          set CurrentLine [lindex $R(Data) $R(Counter)]
          
          switch $State {
               0 {
                    # Check for section header.
                    # If cannot find it then there is nothing to preserve.
                    if {[string equal $CurrentLine $SectionHeader]} {
                         set State 1
                    } else {
                         break
                    }
               }
               1 {
                    # Scanning between section begin and end,
                    # not (yet) in a subsection.
                    # If we hit the section footer, we are done.
                    # If we hit a subsection then we start scanning and saving that.
                    if {[string equal $CurrentLine $SectionFooter]} {
                         break
                    }
                    if {[regexp {\u00a7 Subsection (\w+) Begin \u00a7} $CurrentLine All Subsection] == 1} {
                         set State 2
                         set R($Subsection) ""
                    }
               }
               2 {
                    # Scanning between subsection begin and end.
                    # If we hit the end then turn the subsection into a replacement.
                    # Otherwise, add what we scanned to temp storage.
                    set Temp "\u00a7 Subsection $Subsection End \u00a7"
                    if {[regexp $Temp $CurrentLine All] == 1} {
                         set State 1
                         set SSS "\u00a7 Subsection $Subsection Begin \u00a7"
                         set R($Subsection) [string trimright $R($Subsection)]
                         set PhiareC($SSS) "$SSS\n$R($Subsection)"
                    } else {
                         append R($Subsection) "$CurrentLine\n"
                    }
               }
          }
     }
     
     # Take what we read in and split it into separate strings, one per line.
     set TempData [split $FileData "\n"]
     Debug "Read in $TempData"
     
     # Put the section header at the beginning and footer at the end.
     if {$R(OutputFlag) != 0} {
          lvarpush TempData $SectionHeader 0
          lappend TempData $SectionFooter
     } else {
          Debug "!! Suppressing headers"
     }
     
     # Insert each string into the input vector so we can process after we return.
     for {set i 0} {$i < [llength $TempData]} {incr i} {
          set Index [expr $R(Counter) + $i]
          set String [lindex $TempData $i]
          lvarpush R(Data) $String $Index
     }
     
     # Set up the counter to begin from the start of the lines we just added.
     set R(LineCount) [llength $R(Data)]
     set R(Counter) $SavedCounter
     
     # Return, ready to start processing.
}

proc PullSection2 {args} {
     global R
     global PhiareC
     
     set SavedCounter $R(Counter)
     set sql [join $args " "]
     
     # Run query and get data
     set Result [mydb eval $sql]
     
     
     set SectionHeader "// \u00a7> $sql <\u00a7"
     set SectionFooter "// \u00a7< $sql >\u00a7"
     
     # Scan ahead for any subsections to preserve.     
     set State 0
     for {incr R(Counter)} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          set CurrentLine [lindex $R(Data) $R(Counter)]
          
          switch $State {
               0 {
                    # Check for section header.
                    # If cannot find it then there is nothing to preserve.
                    if {[string equal $CurrentLine $SectionHeader]} {
                         set State 1
                    } else {
                         break
                    }
               }
               1 {
                    # Scanning between section begin and end,
                    # not (yet) in a subsection.
                    # If we hit the section footer, we are done.
                    # If we hit a subsection then we start scanning and saving that.
                    if {[string equal $CurrentLine $SectionFooter]} {
                         set Popped [lvarpop R(Data) $R(Counter)]
                         break
                    }
                    if {[regexp {\u00a7 Subsection (\w+) Begin \u00a7} $CurrentLine All Subsection] == 1} {
                         set State 2
                         set R($Subsection) ""
                    }
               }
               2 {
                    # Scanning between subsection begin and end.
                    # If we hit the end then turn the subsection into a phiare.
                    # Otherwise, add what we scanned to temp storage.
                    if {[regexp {\u00a7 Subsection (\w+) End \u00a7} $CurrentLine All Subsection] == 1} {
                         set State 1
                         set SSS "\u00a7 Subsection $Subsection Begin \u00a7"
                         set R($Subsection) [string trimright $R($Subsection)]
                         set PhiareC($SSS) "$SSS\n$R($Subsection)"                         
                    } else {
                         append R($Subsection) "$CurrentLine\n"
                    }
               }
          }
          if {$State != 2} {
               set Popped [lvarpop R(Data) $R(Counter)]
               set R(Counter) [expr $R(Counter) - 1]
          }
     }
     
     # Take what we read in and split it into separate strings, one per line.
     set TempData [split [join $Result] "\n"]
     
     # Put the section header at the beginning and footer at end.
     if {$R(OutputFlag) != 0} {
          lvarpush TempData $SectionHeader 0
          lappend TempData $SectionFooter
     }
     
     # Insert each string into the input vector so we can process after we return.
     for {set i 0} {$i < [llength $TempData]} {incr i} {
          set Index [expr $R(Counter) + $i]
          set String [lindex $TempData $i]
          lvarpush R(Data) $String $Index
     }
     
     # Set up the counter to begin from the start of the lines we just added.
     set R(LineCount) [llength $R(Data)]
     set R(Counter) $SavedCounter
     
     # Return, ready to start processing.
}

proc EvalSection {} {
     global R
     global PhiareC
     set EOS "#endif"
     
     Debug "Begin eval section"
     # Go through each line and evaluate it at global scope,
     # but quit if hit EOS.
     for {incr R(Counter)} {$R(Counter) < $R(LineCount)} {incr R(Counter)} {
          set R(CurrentLine) [lindex $R(Data) $R(Counter)]
          puts "  | $R(CurrentLine)"
          puts $R(FP) $R(CurrentLine)
          if {[string equal $EOS $R(CurrentLine)]} {
               break
          }
          Debug "Running $R(CurrentLine)"
          uplevel #0 $R(CurrentLine)
     }
     Debug "End eval section"
}

}
