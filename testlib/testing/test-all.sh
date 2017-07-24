
if ! make ; then
	exit;
fi


T="emp osv gmis ginv gsv gwe gwr mis dif ext cor "
for i in $T ; do
	echo ans $i:
	./checker.exe 01.in $i.out 01.out
	echo $?
	echo =========
done
for i in $T ; do
	echo out $i:
	./checker.exe 01.in 01.out $i.out
	echo $?
	echo =========
done
