@set dest=C:\msys\scripts

@echo Copying files tps.sh and tps.bat to '%dest%'
@copy tps.sh "%dest%"
@copy tps.sh "%dest%\tps"
@copy tps.bat "%dest%" 

@echo Make sure that '%dest%' is in PATH.
