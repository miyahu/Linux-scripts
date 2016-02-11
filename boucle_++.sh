mytab1=()
mytab2=()
for a in {1..10} ; do
        if (($a<=5)) ; then
                mytab1+=("$a")
                if (($a==5)) ; then
                        for i in {1..4} ; do
                                echo ${mytab1[0]} ${mytab1[$i]} 
                        done
                fi
        fi
        if (($a>=6)) ; then
                mytab2+=("$a")
                if (($a==10)) ; then
                        for i in {1..4} ; do
                                echo ${mytab2[0]} ${mytab2[$i]}
                        done
                fi
        fi
done

