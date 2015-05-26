# for reseting version number so the next build is *-1
make clean
rm .theos/packages/*
rm .theos/last_package
echo "You're good to go! Just change the version number in your control file to whatever you want!"
exit 0
