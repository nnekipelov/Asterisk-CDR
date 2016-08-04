#!/bin/sh
MY_USER=freepbxuser
MY_PWD=<PASSWORD>
DIR=/var/spool/asterisk/monitor
IFS="
"
MyFiles=$(mysql -u${MY_USER} -p${MY_PWD} <<< "SELECT recordingfile FROM asteriskcdrdb.cdr where recordingfile like '%.wav';")
for CurFile in ${MyFiles}; do
        if [[ "${CurFile}" != "recordingfile" ]];       then
                filedate_array=$(mysql -u${MY_USER} -p${MY_PWD} <<< "SELECT calldate FROM asteriskcdrdb.cdr WHERE recordingfile = '${CurFile}' limit 1;")
                CurFiledate=${filedate_array#calldate${IFS}}
                Year=${CurFiledate:0:4}
                Month=${CurFiledate:5:2}
                Day=${CurFiledate:8:2}
                file_base=${CurFile:0:${#CurFile}-4}
                file_source=${CurFile}
                file_dest="${file_base}.mp3"
#               echo "${file_dest}"
                echo "lame --abr 64  ${DIR}/${Year}/${Month}/${Day}/${file_source} ${DIR}/${Year}/${Month}/${Day}/${file_dest}"
                lame --abr 64  ${DIR}/${Year}/${Month}/${Day}/${file_source} ${DIR}/${Year}/${Month}/${Day}/${file_dest}
                chown asterisk:asterisk ${DIR}/${Year}/${Month}/${Day}/${file_dest}
                chmod 664 ${DIR}/${Year}/${Month}/${Day}/${file_dest}
                mysql -u${MY_USER} -p${MY_PWD} <<< "UPDATE asteriskcdrdb.cdr SET recordingfile = '${file_dest}' WHERE recordingfile = '${CurFile}';"
                rm -f ${DIR}/${Year}/${Month}/${Day}/${file_source}
        fi
done