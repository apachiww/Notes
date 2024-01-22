#!/bin/awk -f

## Initialize
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

## Status flag for code block checking
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

## If headings detected
/^#+ / && (FNR != 1) && ($2 != "目录") && (in_block != 1) {
    # Convert headings to index link
    index_link = gensub(/^#+ /, "", "g", tolower($0))
    gsub(/ /, "-", index_link)
    gsub(/-/, "A", index_link)
    gsub(/_/, "B", index_link)
    gsub(/\r|[[:punct:]]/, "", index_link)
    gsub(/A/, "-", index_link)
    gsub(/B/, "_", index_link)
    # Store links in hashtable to check for duplicate links
    if (index_hash[index_link]) {
        index_hash[index_link]++
        index_link = index_link "-" index_hash[index_link]-1
    } else {
        index_hash[index_link] = 1
    }
    # Convert headings to index name displayed
    index_name = gensub(/^#+ ([0-9]+(\.[0-9]+)* )?|\r/, "", "g", $0)
    # For different headings
    if ($0 ~ /^### [0-9]+(\.[0-9]+){2} /) {
        index_cnt++
        index_arr[index_cnt] = "        + [**" $2 "**](#" index_link ") " index_name
    } else if ($0 ~ /^## [0-9]+\.[0-9]+ /) {
        index_cnt++
        index_arr[index_cnt] = "    + [**" $2 "**](#" index_link ") " index_name
    } else if ($0 ~ /^## [0-9]+ /) {
        index_cnt++
        index_arr[index_cnt] = "+ [**" $2 "**](#" index_link ") " index_name
    } else if ($0 ~ /^# /) {
        index_cnt++
        index_arr[index_cnt] = "+ [**" index_name "**](#" index_link ")"
    } else {
        index_err_cnt++
        index_err[index_err_cnt] = FNR
    }
}

## Print index and check errors
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