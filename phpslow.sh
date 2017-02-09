#===============================================================
#author cyuxlif
#php慢日志分析
#
#使用方法示例: chmod +x ./phpslow.sh
#./phpslow.sh -a bbs.log.slow   // bbs.log.slow 为慢日志文件
#可选择日期./phpslow.sh -a bbs.log.slow --since 2015-07-28 --until 2015-07-28 -n 30
#--since 表示开始时间 后面跟日期， --until表示结束时间
#-n表示最终显示的条数
#
#统计每分钟产生的慢日志条数 使用方法为 ./phpslow.sh -s bbs.log.slow   // bbs.log.slow 为慢日志文件 就是把-a换成-s 其它都一样，同样可选择时间
#
#===============================================================



#!/bin/bash

eval set -- `getopt -o "a:s:n:h" -l "since:,until:,help" -- "$@"`

SHOW_LINE=30
SINCE_LINE="1"
UNTIL_LINE="\$"

ACTION="a"

while true; do
    case "${1}" in
        -a) 
      LOGFILE="${2}"
          shift 2
          ;;
        -s)
          ACTION="s"
      LOGFILE="${2}"
          shift 2
          ;;
    -n)
      SHOW_LINE="${2}"
      shift 2
          ;;
        --since) 
      SINCE_DATE=`env LANG=en_US.UTF-8 date -d ${2} +%d-%b-%Y`
          shift 2
          ;;
        --until) 
      UNTIL_DATE=`env LANG=en_US.UTF-8 date -d ${2} +%d-%b-%Y`
          shift 2
          ;;
        -h|--help) 
          echo -e "${0} 用法:\n[-a 日志文件]\n[-n 显示条数]]\n[--since 日期]\n[--until 日期]\n[-s 日志文件]"
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

if [ $ACTION == "a" ]; then
    #sed -n "${SINCE_LINE},${UNTIL_LINE}p" $LOGFILE 显示起止行
    #sed "s/\[0x.*\] //;/pool www/d" 分别为删除[0x00007fe2e81f8500]类似字样， 删除[30-Jul-2015 14:16:12]  [pool www] pid 35163 类似行
    #awk -v RS="" '{gsub("\n", "|");print}'以空行为awk单位 并将以上处理过的换行替换成| 这样所有执行堆栈为一个整体 方便统计 和后面替换
    #| sort | uniq -c | sort -nr | head -n $SHOW_LINE | 统计排序
    #sed "s/|/\n\t/g" 替换|回换行符       
    sed -n "${SINCE_LINE},${UNTIL_LINE}p" $LOGFILE | sed "s/\[0x.*\] //;/pool www/d" | awk -v RS="" '{gsub("\n", "|");print}' | sort | uniq -c | sort -nr | head -n $SHOW_LINE | sed "s/|/\n\t/g"

fi


if [ $ACTION == "s" ]; then
    sed -n "${SINCE_LINE},${UNTIL_LINE}p" $LOGFILE | grep 'pool www' | cut -d " " -f 2 | cut -d : -f 1,2 | sort | uniq -c | sort -nr | head -n $SHOW_LINE
fi
