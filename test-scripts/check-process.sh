#echo CHECK PROGESS $1
if ps -p $1 > /dev/null
then
   echo "$1 is running"
   # Do something knowing the pid exists, i.e. the process with $PID is running
else
  echo "STOPPED"
fi
