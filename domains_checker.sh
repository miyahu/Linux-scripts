#!/bin/bash -

my_domains=""
my_outfile=/tmp/domains_checker.out

if [ -f $my_outfile ] ; then
        rm $my_outfile
fi
if [[ $1 != "" ]] ; then
        my_type="-t $1"
else
        my_type=""
fi
for i in $my_domains ; do
        echo "$i $(host $my_type $i)" >> $my_outfile
done

