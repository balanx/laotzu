#! /bin/bash

t=0
n=0


for dirs in `ls`
do
    if [ ! -d $dirs ]; then
        continue
    fi

    echo
    echo $dirs/
    cd $dirs
    rm -f iv.log

    for file in `ls *.log`
    do
        let t++
        pat=${file%.*}
        iverilog  -f sim.f  -D PATTERN=\"./$pat.inc\"
        ./a.out > ./iv.log

        diff iv.log $pat.log

        if test $? -eq 0
        then
            printf "    %-30s OK\n" $pat
            let n++
        else
            printf "\nError in '%s'\n" $pat
        fi
    done

    rm iv.log a.out *.dump
    cd ..
done

echo -e '\n'$n/$t Passed.
