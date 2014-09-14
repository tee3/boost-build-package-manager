B2 = b2
B2FLAGS =

all:

test: vcs-archive vcs-git vcs-svn vcs package-manager

package-manager:
	cd test/$@ ; $(B2) -a

vcs:
	cd test/$@ && $(B2) -a

vcs-archive:
	cd test/$@ && $(B2) -a

vcs-git:
	cd test/$@ && $(B2) -a

vcs-svn:
	cd test/$@ && $(B2) -a
