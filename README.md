# Awk:  Hack the Planet['s text]!

[Slides](https://raw.githubusercontent.com/FreedomBen/awk-hack-the-planet/master/Slides%20for%20Awk-%20Hack%20the%20planet%5B's%20text%5D.pdf)
and source code to go along with Ben Porter's Awk talk at Linux Fest Northwest 2019

NOTE:  For those interested in the recording of the talk, I was informed that because it was a "tutorial" talk it was not recorded.

I am planning to record the talk and put it on YouTube myself, and I will link to it here.  I was just suitably chastised for my slacking and will try to get this done soon.

If you want to contact me:

Email:  FreedomBen@protonmail.com
Keybase.io :  https://keybase.io/freedomben
Twitter:  @Freedom_Ben


## The Scenario

The boss has given us a tsv file full of payroll data, and she would like us to run some
analysis on it.  We recently learned about `awk` and it's amazing processing power,
and have decided this is an awesome chance to use our new skillz!

You should primarily use awk, but you can (and should) combine with other tools (like sort, uniq)
when it makes sense.   Don’t use grep or sed tho since awk can handle the same scenarios
(and you are trying to learn awk after all) :-)

The payroll file is `payroll.tsv`.  You can generate a new one with the provided ruby script
if you’d like to randomize it.

There are many different solutions.  The ones presented are just mine.  Many of them could be optimized and refactored to be more elegant.  To run my solutions, use (but substitute the number for the one you are trying to run):

```bash
awk -f 01.awk payroll.tsv
```

Some solutions are bash scripts, in which case just run them like normal:

```bash
./09-awk.sh
```

## Challenges

1. What is the name of the CEO?  Format like "LastName, FirstName"?
2. How much money per hour does the janitor make?
3. Which employees were hired on April 16, 1993? (Print the list)
4. Who is the highest paid employee?
5. How many mechanical engineers work here?
6. Who worked the most hours this week?
7. Who was the first employee hired?
8. Which employee works in the Springfield office?
9. How many different office locations does the company have?
10. How many people from the Portwood family work here?
11. Are there any employees with identical first & last names?
12. What is the average wage?
13. Print each column header, along with which column it is.  E.g. The LastName column is the second column, so print "2 - LastName"
14. How much money per hour does the Seattle office cost?
15. How many engineers (of any type) work here?
16. Are there any duplicate entries? (Same names appear more than once)
17. Anonymize the data by removing the first two columns.  Print all remaining columns
