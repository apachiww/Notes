#!/usr/bin/awk -f

BEGIN {
    print ""
    print "   ###########################################"
    print "   #                                         #"
    print "   #  Index generator for markdown notes :)  #"
    print "   #                                         #"
    print "   ###########################################"
    print ""
}

/^##* [0-9]+(\.[0-9]+)* / {
    index_num = gensub(/[[:punct:]]/, "", "g", $2)
    index_name_init = gensub(/^##* [0-9]+(\.[0-9]+)* /, "", "g", $0)
    index_name_init = gensub(/\r/, "", "g", index_name_init)
    index_name = gensub(/ /, "-", "g", index_name_init)
    index_name = tolower(index_name)
    gsub(/-/, "A", index_name)
    gsub(/[[:punct:]]/, "", index_name)
    gsub(/A/, "-", index_name)

    if ($0 ~ /^### [0-9]+(\.[0-9]+){2} /) {
        printf "        + [**%s**](#%s-%s) %s\n", $2, index_num, index_name, index_name_init
    } else if ($0 ~ /^## [0-9]+\.[0-9]+ /) {
        printf "    + [**%s**](#%s-%s) %s\n", $2, index_num, index_name, index_name_init
    } else if ($0 ~ /^## [0-9]+ /) {
        printf "+ [**%s**](#%s-%s) %s\n", $2, index_num, index_name, index_name_init
    } else {
        index_err_cnt++
        index_err[index_err_cnt] = FNR
    }
}

END {
    print ""
    print "   ###########################################"
    print "   #                                         #"
    print "   #                 Hit EOF                 #"
    print "   #                                         #"
    print "   ###########################################"
    print ""
    print "Reports:"
    if (index_err_cnt) {
        printf "%d headings not printed at\n", index_err_cnt
        for (i in index_err) {
            printf "Line %d\n", index_err[i]
        }
        exit 0
    } else {
        print "No error"
        exit 0
    }
}