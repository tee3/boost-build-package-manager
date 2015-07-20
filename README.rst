Boost.Build ``package-manager`` Module
======================================

.. contents::

Overview
--------

This directory contains a ``package-manager`` module for interacting
with 'packages' within Boost.Build and a ``vcs`` module for
interacting with version control systems within Boost.Build.

- `Package Manager <package-manager.rst>`_
- `Version Control Systems (vcs) <vcs.rst>`_

Testing Guidelines
------------------

To run the tests, run the following command.

::

   $ make test

Example
-------

See the `example program <./example>`_.  This is useful in testing and
developing the `package-manager` module.

::

   $ b2 --verbose-test

Issues
~~~~~~

1. The `using package-manager : directory` syntax does not work.

2. The version of a package must be specified in both
   `package-manager.require-package` and
   `package-manager.versioned-package-path`, which is error-prone.

3. Boost.Build packages do not automatically register themselves.

4. Packages do not provide something easily used, which makes
   `package-manager.versioned-package-path` necessary.

4. The current implementation requires two runs of `b2` in order to
   get the packages and then use the packages, which is highly
   unintuitive.

5. There is no dependency on the Boost.Build files to the targets
   within it, so changing the required version for a package does not
   cause rebuilding.
