#!/bin/sh
/opt/bbxmlnewsfeed/bbnewsfetch http://cruise:cruise@go.gen.tradermedia.net/go/cctray.xml P > /opt/bbxmlnewsfeed/cctray.xml
/opt/bbxml/bin/bbxml2 /opt/bbxmlnewsfeed/cctray.xml

