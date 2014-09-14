TETRAMA
     Text Translation 
          Transduction
          Tranformation Machine

README

CONTENTS OF THIS FILE
---------------------
01| HOW TO USE THIS DOCUMENT
02| INTRO
03| GETTING STARTED
04| BUILDING
05| INSTALLATION
06| CONFIGURATION
07| MANUAL
08| FAQ
09| PLATFORM NOTES
10| TROUBLESHOOTING
11| KNOWN ISSUES
12| BUG REPORTING
13| FEEDBACK
14| TESTING
15| CONTRIBUTING
16| UPDATING
17| RECENT CHANGES
18| LICENSE
19| LEGAL
20| CREDITS

---01| HOW TO USE THIS DOCUMENT

Prefer to use the website for better and more up-to-date info instead. 

What is the software about?
Processing text. It is like a preprocessor, but more powerful. See INTRO.

Is it OK for me to use? OK for me to modify? OK to make copies?
See LICENSE for info about the software license.
See LEGAL for any additional info.

How do I get it working?
See GETTING STARTED (after you have it installed and configured) to see how to use.
See BUILDING for how to compile from source.
See INSTALLATION for how to install it on your system (and how to uninstall).
See CONFIGURATION for how you can customize it for your own use.

I cannot make it work, what now?
See TROUBLESHOOTING for dealing with problems with the software.
See PLATFORM NOTES for ensuring it works with your platform/OS.
See MANUAL to make sure you are using it correctly.
See FAQ to see if your question has been answered.
See KNOWN ISSUES to see if your problem is already known about (and any workarounds / advice).
See BUG REPORTING if you want to make a report and get follow-up.

What is in the other sections?
FEEDBACK - Info about things like feature requests.
TESTING - How you can test changes you make to the code.
CONTRIBUTING - How you improve the product for everyone.
UPDATING - How to get the latest changes.
RECENT CHANGES - What the latest changest are.
CREDITS - Third party components used.

---02| INTRO

Tetrama is supposed to solve a few basic problems that I did not find a simple solution for.

1: Preprocess C/C++ files by reading in lists of things from databases.

There is no preprocessor directive that lets you do this. But if can generate web pages from database queries then should be able to do it for C/C++ (or anything else) as well. No reason why not, so I made a solution.

2: Not happy with writing web pages in PHP.

Rather than write:

<? echo "<h1>$XYZ</h1>" ?>

I would rather do something like this:

<h1>XYZ</h1>

I still use PHP, so Tetrama is not intended as replacement for PHP but rather to let me do certain things the way I want to do them.

Those are the main things it tries to do. Again, (1) be able to read in from a database and (2) simple find/replace. It does a few more things (and more are planned) but it is supposed to be simple and does not try to be a programming language.

---03| GETTING STARTED

1. Run the sample like this:

> tclsh Tetrama.tcl samples/helloworld.pre.txt samples/helloworld.txt

Compare the files and see what changed.

There are lots of other samples to try. Best way to get going is to view the diff between them to see what Tetrama is capable of. Then try making any experimental changes to the samples and see what happens. That is the simplest way to get going. To make use of it in your own projects, you can usually start by taking some sample and then start tweaking it until it does what you want.

2. Use it from your own TCL scripts like this:

package require tetrama
Tetrama samples/helloworld.pre.txt samples/helloworld.txt

For more details see MANUAL.txt.

---04| BUILDING

Package is provided as TCL scripts. No need to build.

---05| INSTALLING

To install, unzip tetrama.zip in the directory of your choice. That will result in the following files:

README.txt
     What you are reading now.
LICENSE.txt
     Terms of use and whatnot.
pkgIndex.tcl
     Used by TCL package mechanism.
Tetrama.tcl
     Handles command line options for if you want to call from command line.
TetramaBase.tcl
     Main package.
/doc
     Any other documents like the manual.
/samples
     To learn from and adapt to your own uses.

For the current version, it is required that you have TCL installed.

If you want "package require Tetrama" to work, then TCL has to be able to find the package. For TCL to find the package you need to either (1) Make it in a subdirectory of where TCL is already looking -OR- (2) Add the directory where you put it to the path.

You can get the path with "puts $auto_path". Personally, I add my directories to the path. I did so by adding this line to my init.tcl:

lappend ::auto_path PATH_TO_TETRAMA_DIR

and I found my init.tcl in C:\Tcl\lib\tcl8.5 (but your location may differ).

If pathing is too troublesome, you can still use "source PATH_TO_TETRAMA_FILE" instead.

---06| CONFIGURATION

No configuration necessary to get started or for basic usage.

For options / settings, see MANUAL.txt.

---07| MANUAL

See doc/MANUAL.txt or http://www.robertbrogan.com/tetrama/manual.html.

---08| FAQ

No questions yet.

Please send questions you have to :

tetrama.questions@robertbrogan.com or visit http://www.robertbrogan.com/tetrama/feedback.html.

Also note, you may possibly find the answer to your question in MANUAL, PLATFORM NOTES, TROUBLESHOOTING, or KNOWN ISSUES.

---09| PLATFORM NOTES

This project was developed on Windows Vista, using TCL 8.5 ActiveState distribution.

TCL is an interpreted language and I am not aware of any platform dependencies.

---10| TROUBLESHOOTING

1! Issues with "package require tetrama"

See INSTALLING for advice.

Also note, you may possibly find help in MANUAL, PLATFORM NOTES, FAQ, or KNOWN ISSUES.

If you like you may send a question to:

tetrama.questions@robertbrogan.com or visit http://www.robertbrogan.com/tetrama/feedback.html.

---11| KNOWN ISSUES

None at this time.

For a more up-to-date list, you can visit:

http://www.robertbrogan.com/tetrama/knownissues.html.

---12| BUG REPORTING

Visit http://www.robertbrogan.com/tetrama/feedback.html. 

Alternatively, send an email to one of:

tetrama.questions@robertbrogan.com
tetrama.comments@robertbrogan.com
tetrama.bugreport@robertbrogan.com
tetrama.wishlist@robertbrogan.com
tetrama.other@robertbrogan.com

and we will try to get back to you ASAP.

---13| FEEDBACK

Visit http://www.robertbrogan.com/tetrama/feedback.html. 

Alternatively, send an email to one of:

tetrama.questions@robertbrogan.com
tetrama.comments@robertbrogan.com
tetrama.bugreport@robertbrogan.com
tetrama.wishlist@robertbrogan.com
tetrama.other@robertbrogan.com

and we will try to get back to you ASAP.

---14| TESTING

Currently, there are no tests. You may wish to use the files in /samples as tests.

If and when there are tests, they will be added to a directory called 'test'.

---15| CONTRIBUTING

Nothing formal has been set up for governing this project, yet.

If you like, you may change the code yourself and submit a patch to:

tetrama.bugreport@robertbrogan.com (for bug fixes)
-or-
tetrama.wishlist@robertbrogan.com (for features you implemented)

A roadmap (planned changes) and wishlist (unplanned) are available at:

http://www.robertbrogan.com/tetrama/roadmap.html
http://www.robertbrogan.com/tetrama/wishlist.html

You may want to get involved by submitting wishlist items and/or offering to do work listed in the above two pages. 

---16| UPDATING

The latest version can be found at http://www.robertbrogan.com/tetrama/download.html.

No announcements mechanism has been set up yet. When it is, information for how to subscribe will be put on the above page.

---17| RECENT CHANGES

Initial revision. No changes yet.

---18| LICENSE

See LICENSE.txt

---19| LEGAL

No legal notice at this time (i.e. no use of crypto). See LICENSE.txt for information about the license.

---20| CREDITS

Developed using Notepad++ and ActiveState ActiveTcl 8.5.4.0.

wiki.tcl.tk has been a useful resource.
