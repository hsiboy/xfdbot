#!/bin/sh
/opt/bbxml/bin/bbxml2 /opt/bbxmlnewsfeed/setup.xml
/opt/bbxml/bin/bbtime
/opt/bbxmlnewsfeed/bbnewsfetch http://stuart-t:fy9nhf@cruise.dev.tradermedia.net/cruise/cctray.xml P | /opt/bbxml/bin/bbxml2
/opt/bbxmlnewsfeed/bbnewsfetch http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/uk/rss.xml B | /opt/bbxml/bin/bbxml2
/opt/bbxmlnewsfeed/bbnewsfetch http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/technology/rss.xml C | /opt/bbxml/bin/bbxml2
/opt/bbxmlnewsfeed/bbnewsfetch http://www.google.com/ig/api?weather=wa12%200he W | /opt/bbxml/bin/bbxml2
