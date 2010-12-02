p(0) - Puppet Language Level Zero
=================================

p(0), or 'pzero', is a stand-alone project for parsing and generating
a simplified form of [Puppet http://puppetlabs.com]'s already simple configuration language.
The difference between this language and the full language is that this
minimal version includes no variables, class constructs, or conditionals of
any kind, similarly to how JSON is a pure-data subset of Javascript:

Puppet : p(0) :: Javascript : JSON

The point of the p(0) is that it can be easily written and parsed in
non-Ruby languages without any Puppet dependencies, just like JSON (although
admittedly more difficult than JSON).  It is both a language spec and
an implementation of that spec in as many languages as possible.  It is
also expected that some or all of those implementations will move into separate
projects, such as ruby gems and python eggs.

p(0) is effectively a simplified graph language, with Puppet Resources being
the nodes and dependencies being the edges.
