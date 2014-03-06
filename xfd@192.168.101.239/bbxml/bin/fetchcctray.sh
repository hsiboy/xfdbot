#!/bin/sh
/opt/bbxmlnewsfeed/bbnewsfetch http://stuart-t:fy9nhf@cruise.dev.tradermedia.net/cruise/cctray.xml P > /opt/bbxmlnewsfeed/cctray.xml
/opt/bbxml/bin/bbxml2 /opt/bbxmlnewsfeed/cctray.xml

