B2 = b2
B2FLAGS =

all:

test: vcs-git vcs-svn vcs

vcs:
	cd test/$@ && $(B2) -a

vcs-git:
	cd test/$@ && $(B2) -a

vcs-svn:
	cd test/$@ && $(B2) -a
