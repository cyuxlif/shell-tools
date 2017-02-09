#===============================================================
#author cyuxlif
#nginx简单统计分析
#
#使用方法示例: chmod +x ./nginx_simple.sh
#./nginx_simple.sh -a www.bbs.nginx_access.log   // nginx_access.log为nginx日志
#可选类型./nginx_simple.sh -a www.bbs.nginx_access.log -t url // nginx_access.log为nginx日志 -t url根据 url频次排序,-t ip根据ip频次排序
#可选择日期./nginx_simple.sh -a www.bbs.nginx_access.log --since "2015-10-21 05" --until "2015-10-21 07" -n 50
#--since 表示开始时间 后面跟日期， --until表示结束时间
#-n表示最终显示的条数
#
#
#===============================================================



#!/bin/bash

eval set -- `getopt -o "a:t:n:h" -l "since:,until:,help" -- "$@"`

SHOW_LINE=50
SINCE_LINE="1"
UNTIL_LINE="\$"

TYPE="url"

while true; do
    case "${1}" in
        -a) 
      LOGFILE="${2}"
          shift 2
          ;;
        -t)
      TYPE="${2}"
          shift 2
          ;;
    -n)
      SHOW_LINE="${2}"
      shift 2
          ;;
        --since) 
      SINCE_DATE=`env LANG=en_US.UTF-8 date -d "${2}" +%d/%b/%Y:%H`
          shift 2
          ;;
        --until) 
      UNTIL_DATE=`env LANG=en_US.UTF-8 date -d "${2}" +%d/%b/%Y:%H`
          shift 2
          ;;
        -h|--help) 
          echo -e "${0} 用法:\n[-a 日志文件]\n[-n 显示条数]]\n[--since 日期]\n[--until 日期]\n[-t 类型:url|ip]"
          exit 0
          ;;
        --) 
      shift 
      break 
      ;;
        *) 
      echo "使用${0} [-h|--help]查看帮助" 
      exit 0 
      ;;
    esac
done

if [ ! -f "$LOGFILE" ]; then
    echo "error:日志文件不存在"
    exit 0
fi

#起始日期 行
if [ $SINCE_DATE ]; then
    SINCE_LINE=`grep -n ${SINCE_DATE} ${LOGFILE} | head -n 1 | cut -d : -f 1`
    SINCE_LINE=${SINCE_LINE:="1"}
fi

#终止日期 行
if [ $UNTIL_DATE ]; then
    UNTIL_LINE=`grep -n ${UNTIL_DATE} ${LOGFILE} | tail -n 1 | cut -d : -f 1`
    UNTIL_LINE=${UNTIL_LINE:="\$"}
fi  

if [ $TYPE == "url" ]; then
    #$8 根据nginx日志配置格式自行调整
    sed -n "${SINCE_LINE},${UNTIL_LINE}p" $LOGFILE |awk '{print $8}' | sort | uniq -c | sort -nr | head -n $SHOW_LINE
fi

if [ $TYPE == "ip" ]; then
    sed -n "${SINCE_LINE},${UNTIL_LINE}p" $LOGFILE |awk '{print $1}' | sort | uniq -c | sort -nr | head -n $SHOW_LINE
fi
