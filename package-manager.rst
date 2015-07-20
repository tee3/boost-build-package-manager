Boost.Build ``package-manager`` module
======================================

.. contents::

Overview
--------

The ``package-manager`` module allows Boost.Build projects to specify
external dependencies as packages as part of a Boost.Build project or
in a simple configuration file format.  The ``package-manager`` module
is responsible for getting the package from the given URL and
providing enough information about the package for users to use.

The packages will be downloaded and placed in a central location for
all Boost.Build projects to use.  The ``package-manager`` verifies the
package whenever it is used and packages are never modified after
their initial "fetch" and "checkout".  It is an error if a package
directory does not match it's specifications and it is left to the
user to resolve the issue.

It is intended that this only be used to manage released versions of
packages.  The system actually supports any symbolic reference, but
the implications of using this are too complicated for repeatable
behavior or when multiple projects are sharing a single package, so it
is not a recommended use case.

There are some existing tools that do something similar, but none yet
seems to solve the whole problem.  The ``package-manager`` does not
solve the whole problem either, but it is portable across all systems
that support Boost.Build and the required version control systems.
While the version control system interaction is currently written in
Boost.Build and the command-line clients, it would be straightforward
to replace this code with another tool.

We define the following terms for the purposes of this document.

package

   A directory tree containing the source of a project.  This will
   typically be hosted in an accessible version control system or as
   web-accessible archive files.

Boost.Build project

   Any project that uses Boost.Build as its build system.  Support for
   a certain type of Boost.Build projects will be automatic.

   Note that automatic support for other build systems is problematic
   for source repositories, but it may be possible to support a very
   small subset that provide the right properties.

Motivation
----------

The ``package-manager`` module is a simple and portable alternative to
the using native version control system approach (Git submodules,
Subversion ``svn:externals`` properties, etc.) for referencing
external package dependencies.

It also simplifies the set up of projects the utilize Boost.Build as a
build system with very little to no configuration in the package
projects.  The example below shows a complete example.

::

   using package-manager : path/to/packages ;

   package-manager.require-package project-a
      : 1.0
      : https://example.com/svn/project-a
      : svn
      : boost.build
      ;
   package-manager.require-package project-b
      : 2.0
      : https://example.com/git/project-b
      : git
      : boost.build
      ;

   exe example
      : # sources
         example.cpp

	 /package-manager//project-a
	 /package-manager//project-b
      ;

.. note::
   Note that the properties above could be the basis of a package
   configuration file format.  This could be considered an improvement
   over putting the configuration directly in a Boost.Build control
   file as it could be easily translated for use by some future system
   that provides a more fully-featured package management system.

::

   # .bpmconfig
   [project-a]
      symbolic-ref = 1.0
      root-url = http://example.com/svn/project-a
      vcs = svn
      build-system = boost.build
   [project-b]
      symbolic-ref = 2.0
      root-url = http://example.com/svn/project-b
      vcs = git
      build-system = boost.build

::

   # detect and use existing .bpmconfig or .gitmodules or svn:externals
   # properties, or alternatively the name of the package configuration
   # can be given

   using package-manager ;

   exe example
      : # sources
         example.cpp

	 /package-manager//project-a
	 /package-manager//project-b
      ;

Challenges of Version Control System-specific Approaches
--------------------------------------------------------

There are several challenging issues with using version control
system-specific tools.

Switching version control systems is challenging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All dependencies must be converted to the new version control system.

Supporting multiple version control systems is impractical
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some services provide multiple interfaces to a repository.  For
example, GitHub provides Subversion client access to Git repositories
hosted at GitHub.  While these repositories can be used by a
native Subversion project as an ``svn:externals``, they do not
translate Git submodules to the Subversion client.

Supporting multiple version control systems for dependencies is impractical
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The chosen version control system must support all the version control
systems used by all dependencies.  Currently, it is exceedingly rare
for any version control system to support another in this way.

Rewriting history of any repository is impractical
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While rewriting history is a controversial topic, it is sometimes
necessary or useful to do so.  Depending on the approach taken in the
version control system, rewriting the history of any project may break
projects that have the rewritten project as dependency. With a
distributed version control system (DOCS), it is impossible to know if
any projects depend on the rewritten project.

Note that this wouldn't necessarily have to be if some rules were
enforced in the usage or specification of dependencies.  However, Git
submodules are specified with an actual SHA-1 reference describing the
commit, which will break when the history of a dependency is
rewritten.  Furthermore, once the Git repository of the dependency is
garbage-collected, the original SHA-1 referenced in the dependent
project will no longer exist and recovering it would be impractical.

Usage
-----

::

   using package-manager ;

   # list source project dependencies
   package-manager.require-package package-a
      : 1.0
      : https://example.com/svn/package-a
      : svn
      : boost-build
      ;
   package-manager.require-package package-b
      : 2.0
      : https://example.com/git/package-b
      : git
      : boost-build
      ;
   package-manager.require-package package-c
      : 2.0
      : https://example.com/git/package-c
      : git
      : boost-build
      ;

   # note that the usage of the source packages is package-dependent,
   # as designed

   # using a Boost.Build package
   #
   # @todo we should do this for them since we don't want them to have
   # to repeat the version (and the name, but the version changes)
   alias package-a
      : sources
         [ package-manager.location package-a : 1.0 ]/path/to/boost-build-jamfile
      ;
   alias package-b
      : sources
         [ package-manager.location package-b : 2.0 ]/path/to/boost-build-jamfile
      ;
   alias package-c
      : sources
         [ package-manager.location package-c : 2.0 ]/path/to/boost-build-jamfile
      ;

   # @todo with Boost.Build support
   # exe example : example.cpp /package-manager/package-a-1.0 ;
   exe example : example.cpp package-a ;

Reference
---------

``init ( directory )``

   Initializes the package manager, with packages stored at the
   indicated directory.

``detect-configuration ( directory )``

   NOTE: THIS IS NOT IMPLEMENTED YET

   Automatically creates required packages from querying the
   filesystem at the indicated directory.  This can generate required
   packages from either a ``.gitmodules`` file or ``svn:externals``
   Subversion properties on the root directory.

``require-package ( name : symbolic-ref : root-url : vcs : build-system ? )``

   Indicates to the package manager that the package named at the
   revision indicated by a symbolic reference is required by this
   project.

   If the package already exists in the package manager, the system
   just verifies that it is correct.  If the package does not exist,
   it will create a package in the package repository by fetching from
   the indicated URL to the root of the project into a location,
   checking out the symbolic reference.

   If the build system is indicated, this will create an alias for the
   project in Boost.Build.

``installed-packages ( )``

   Returns a list of all the installed packages.

``is-installed ( name : symbolic-ref )``

   Returns true if the package with the indicated name and version are
   installed in the package manager.

``versioned-package-name ( name : symbolic-ref )``

   Returns the package name of a packed with the indicated name and
   version.

   Note that the package does not have to be installed for this to
   return a valid name.

``versioned-package-path ( name : symbolic-ref )``

   Returns the path to the indicated package and version.

   Note that the package does not have to be installed for this to
   return a valid path.

Source
------

Please see the `source code <./package-manager.jam>`_ for the
implementation and the ground truth.
