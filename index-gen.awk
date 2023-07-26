#!/bin/awk -f

BEGIN {
    print "\n\
        ###########################################\n\
        #                                         #\n\
        #  Index generator for markdown notes :)  #\n\
        #                                         #\n\
        ###########################################\n\
    "
}

/^#+ [0-9]+(\.[0-9]+)* / {
    index_name = gensub(/^#+ [0-9]+(\.[0-9]+)* |\r/, "", "g", $0)
    index_link = gensub(/^#+ /, "", "g", tolower($0))
    gsub(/ /, "-", index_link)
    gsub(/-/, "A", index_link)
    gsub(/_/, "B", index_link)
    gsub(/\r|[[:punct:]]/, "", index_link)
    gsub(/A/, "-", index_link)
    gsub(/B/, "_", index_link)
    index_string = "[**" $2 "**](#" index_link ") " index_name
    if ($0 ~ /^### [0-9]+(\.[0-9]+){2} /) {
        printf "        + %s\n", index_string
    } else if ($0 ~ /^## [0-9]+\.[0-9]+ /) {
        printf "    + %s\n", index_string
    } else if ($0 ~ /^## [0-9]+ /) {
        printf "+ %s\n", index_string
    } else {
        index_err_cnt++
        index_err[index_err_cnt] = FNR
    }
}

END {
    print "\n\
        ###########################################\n\
        #                                         #\n\
        #             Index generated             #\n\
        #                                         #\n\
        ###########################################\n\
    "
    print "Reports:"
    if (index_err_cnt) {
        printf "%d headings not printed at:\n", index_err_cnt
        for (i in index_err) {
            printf "Line %d\n", index_err[i]
        }
        exit 0
    } else {
        print "No error"
        exit 0
    }
}