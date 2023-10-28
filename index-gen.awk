#!/bin/awk -f

BEGIN {
    print "\n\
        ###########################################\n\
        #                                         #\n\
        #  Index generator for markdown notes :)  #\n\
        #                                         #\n\
        ###########################################\n\
    "
    in_block = 0
}

/^```/ {
    switch (in_block) {
    case 0:
        in_block = 1
        break
    case 1:
        in_block = 0
        break
    default:
        exit 1
    }
}

/^#+ / && (FNR != 1) {
    if (in_block == 1) {
        next
    }
    index_link = gensub(/^#+ /, "", "g", tolower($0))
    gsub(/ /, "-", index_link)
    gsub(/-/, "A", index_link)
    gsub(/_/, "B", index_link)
    gsub(/\r|[[:punct:]]/, "", index_link)
    gsub(/A/, "-", index_link)
    gsub(/B/, "_", index_link)
    if ($0 ~ /^# /) {
        index_name = gensub(/^# |\r/, "", "g", $0)
        index_pri++
        index_pri_arr[index_pri] = index_link
        for (line in index_pri_arr) {
            if (index_pri_arr[line] == index_link) {
                dup_cnt++
            }
        }
        index_cnt++
        if (dup_cnt == 1) {
            index_arr[index_cnt] = "+ [**" index_name "**](#" index_link ")"
        } else {
            index_arr[index_cnt] = "+ [**" index_name "**](#" index_link "-" --dup_cnt ")"
        }
        dup_cnt = 0
    } else {
        index_name = gensub(/^#+ [0-9]+(\.[0-9]+)* |\r/, "", "g", $0)
        index_string = "[**" $2 "**](#" index_link ") " index_name
        if ($0 ~ /^### [0-9]+(\.[0-9]+){2} /) {
            index_cnt++
            index_arr[index_cnt] = "        + " index_string
        } else if ($0 ~ /^## [0-9]+\.[0-9]+ /) {
            index_cnt++
            index_arr[index_cnt] = "    + " index_string
        } else if ($0 ~ /^## [0-9]+ /) {
            index_cnt++
            index_arr[index_cnt] = "+ " index_string
        } else {
            index_err_cnt++
            index_err[index_err_cnt] = FNR
        }
    }
}

END {
    for (line in index_arr) {
        print index_arr[line]
    }
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