#!/bin/bash
user="freepbxuser"
pass="<PASS>"
db="asteriskcdrdb"

#Clear all records except last 90 days

mysql -u"$user" -p"$pass"  <<EOF
use $db;
DELETE FROM cdr WHERE calldate  <= DATE_ADD(NOW(), INTERVAL -90 DAY);
DELETE FROM cel WHERE eventtime <= DATE_ADD(NOW(), INTERVAL -90 DAY);
OPTIMIZE TABLE cdr;
OPTIMIZE TABLE cel;
EOF

#Clear all files except last 90 days
find /var/spool/asterisk/monitor/* -mtime +90 -exec rm {} \;