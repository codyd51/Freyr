# For setting up after cloning from GitHub (getting theos links good)
rm ./theos
ln -s $THEOS ./theos
# Please not that the next part only works when there's one subproject (e.g. a preference bundle)
SUBPROJECTS=`cat Makefile | grep 'SUBPROJECTS' | sed -e 's/.*SUBPROJECTS += //'`
rm ./$SUBPROJECTS/theos
ln -s $THEOS ./$SUBPROJECTS/theos
exit 0