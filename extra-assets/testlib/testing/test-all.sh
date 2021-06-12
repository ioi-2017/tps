
if ! make ; then
	exit;
fi


T="emp onosec gmis ginv gsv gpve gpvr gwe gwr mis dif ext ext2 cor "
for i in $T ; do
	echo out $i:
	./checker.exe 01.in 01.out $i.out
	echo $?
	echo =========
done
