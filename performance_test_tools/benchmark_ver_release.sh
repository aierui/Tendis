log=benchmark.log
logInfo() {
    time=`date +"%Y/%m/%d %H:%M:%S"`
    echo $time $1 >> $log
}

stopTask() {
    ps axu |grep $benmark_binary |grep $user|grep $ipmatch |awk '{print $2}'|xargs kill -9
}

startTask() {
    stopTask

    task=$1
    logInfo "$tendisVersion task begin: $task"
    for((i=0;i<$benchnum;i++))
    do
        if (($i%2 == 0 ))
        then
            ip=$ip1
            port=$port1
        else
            ip=$ip2
            port=$port2
        fi
        if [ "$task" = "set" ]
        then
            nohup $benmark_binary -h $ip -p $port -c $clientnum -n $per_keynum -r 2100000000 -f $i -t set -a $pw -d 256 & 
        elif [ "$task" = "get" ]
        then
            nohup $benmark_binary -h $ip -p $port -c $clientnum -n $per_keynum -r 2100000000 -f $i -t get -a $pw & 
        elif [ $task = "zset" ]
        then
            nohup $benmark_binary -h $ip -p $port -c $clientnum -n $per_keynum -r 2100000000 -f $i -t get -a $pw & 
        fi
    done
}

waitFinish() {
    while ((1))
    do
        num=`ps axu |grep $benmark_binary|grep $user|grep $ipmatch |awk '{print $2}'|wc -l`
        if (($num == 0))
        then
            break
        fi
        sleep 1
    done
    logInfo "$tendisVersion task finished: $1"
}

if [[ $# != 1 ]]
then
    echo "usage: "
    echo "      ./benchmark_ver_release.sh 2-3-0"
    exit 1
fi

#rm nohup.out
#rm $log

logInfo "========start========"
tendisVersion=$1
logInfo "start tendisVersion: $tendisVersion benchmark"

user=mysql
ipmatch=tendisx.cdtest
ip1=tendisx.cdtest-${tendisVersion}.sf.db
ip2=tendisx.cdtest-${tendisVersion}.sf.db
port1=50000
port2=50000
pw=cdtestgo
benmark_binary=./redis-benchmark

let keynum=1*10000*10000
clientnum=100
benchnum=10
let per_keynum=$keynum/$benchnum

#1 yi about 8 minutes
startTask set
waitFinish set
sleep 120

#1 yi about 7 minutes
startTask get
waitFinish get

logInfo "end tendisVersion: $tendisVersion benchmark"
logInfo "========end========"
