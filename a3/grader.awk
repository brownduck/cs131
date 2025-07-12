BEGIN { 
	FS = "," 
}
# user function for average
function average(total, count) {
    return total / count
}
# skip the header
NR > 1 {
    # id is $1, name is $2, everything else are scores
    name = $2
    total = 0
    amountofscores = NF - 2
    # even though the sample gives us only 3 scores, this for loop can add all of the scores 
    # based on the number of fields, assuming all values after id and name are scores
    for (i = 3; i <= NF; i++) {
	total += $i
	   }
    # create the array to assign each key (name) a value (total score), used at the end
    scores[name] = total
    # use that function
    mean = average(total, amountofscores)
    # another array to hold onto scores (for printing everyone's average)
    averages[name] = mean
    # ternary statement to set their fate based on their average
    status[name] = (mean >= 70) ? "Pass" : "Fail"
    # set the max score to the first student and then to anyone higher
    if (NR == 2 || total > max) {
        max = total
        beststudent = name
    }
    # same thing but lower
    if (NR == 2 || total < min) {
        min = total
        worststudent = name
    }
}

END {
    # printing time
    print "Students Analysis:"
    print "|Name        |Total Score   |Average     |Status      | " 
    print "-------------------------------------------------------"
    for (name in scores) {
        printf "|%-12s|%-14.2d|%-12.2f|%-12s|\n", name, scores[name], averages[name], status[name]
    }

    print "-------------------------------------------------------"
    print "\nThe Best Student: " beststudent "(" max ")"
    print "The Worst Student(they're gonna DIE): " worststudent "(" min ")"
}

