#!/usr/bin/env python
#
# Copyright (c) 2010 Timothy Bourke. All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the terms of the "BSD License" which is 
# distributed with the software in the file LICENSE.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the BSD
# License for more details.
#

# to install, add the following line to muttrc:
#   set query_command="query_evolution_contacts.py %s"

# Developed from information at:
# http://commandline.org.uk/python/three-useful-python-bindings/

import sys
from evolution import ebook

queries = sys.argv[1:]
print
if queries == []: sys.exit(0)

email_fields = [ 'email-%i' % i for i in range(1,5) ]

abooks = {} 
for (name, path) in ebook.list_addressbooks():
    abook = ebook.open_addressbook(path)
    if abook is not None:
	abooks[name] = abook

found = []
for query in queries:
    for name in abooks.iterkeys():
	results = abooks[name].search(query)
	for r in results:
	    # r.__doc__ for list of properties
	    name = r.get_name()
	    note = r.get_property('note')
	    if note is None: note = ''

	    for p in email_fields:
		email = r.get_property(p) 
		if (email is not None):
		    found.append((name, email, note))

found.sort()
lf = None
for f in found:
    if f != lf:
	(name, email, note) = f
	print "%s\t%s\t%s" % (email, name, note)
	lf = f

