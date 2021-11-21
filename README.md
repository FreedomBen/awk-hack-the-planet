# Awk:  Hack the Planet['s text]!

[Slides](https://raw.githubusercontent.com/FreedomBen/awk-hack-the-planet/master/Slides%20for%20Awk-%20Hack%20the%20planet%5B's%20text%5D.pdf)
and source code to go along with Ben Porter's Awk talk at Linux Fest Northwest 2020

## Videos from Linux Fest Northwest 2020:

* [Part 1 (Presentation)](https://youtu.be/43BNFcOdBlY) - This is the presentation or lecture explaining Awk syntax and functions
* [Part 2 (Exercises)](https://youtu.be/4UGLsRYDfo8) - This includes me explaining all of the answers to the challenges in the repo

## If you want to contact me:

* Email:  FreedomBen@protonmail.com
* Keybase.io :  https://keybase.io/freedomben
* Twitter:  @Freedom_Ben


## The Scenario

The boss has given us a tsv file full of payroll data, and she would like us to run some
analysis on it.  We recently learned about `awk` and it's amazing processing power,
and have decided this is an awesome chance to use our new skillz!

You should primarily use awk, but you can (and should) combine with other tools (like sort, uniq)
when it makes sense.   Don’t use grep or sed tho since awk can handle the same scenarios
(and you are trying to learn awk after all) :-)

The payroll file is `payroll.tsv`.  You can generate a new one with the provided ruby script
if you’d like to randomize it.

There are many different solutions.  The ones presented are just mine.  Many of them could be optimized and refactored to be more elegant.  To run my solutions (and check my output against yours), use `awk -f <file> payroll.tsv` (but substitute the number for the one you are trying to run):

```bash
awk -f 01.awk payroll.tsv
```

Some solutions are bash scripts, in which case just run them like normal:

```bash
./09-awk.sh
```

## Challenges (Questions to answer about our payroll data using awk to analyze)

### Easy (one-liners)
1. How much money per hour does the janitor make?
2. What is the name of the CEO?  Format like "LastName, FirstName"?
3. Which employees were hired on April 16, 1993? (Print the list)
4. Which employee works in the Springfield office?

### A little harder
5. How many mechanical engineers work here?
6. How many people from the Portwood family work here?
7. Are there any employees with identical first & last names?  (IOW, the first name is the same as the last name.  e.g. Linus Torvalds is not identical, Johnson Johnson is identical)

### Gotta think a bit
8. Print each column header, along with the column number.  E.g. The LastName column is the second column, so print "2 - LastName"
9. How much money per hour does the Seattle office cost to run?  (IOW, how much total per hour does it cost to pay all employees who work out of the Seattle office)
10. How many engineers (of any type) work here?
11. Who is the highest paid employee?
12. Who worked the most hours this week?

### Awk proficient
13. Anonymize the data by removing the first two columns.  Print all remaining columns
14. Our client is complaining about the anonymized data from the previous question.  They say is claiming it is too hard to read.  They would like you to add line numbers to the beginning of each line in the output.
15. How many different office locations does the company have?
16. What is the average (mean) wage of all employees?  What about the median (extra credit)?
17. Are there any duplicate entries? (Same names appearing on payroll more than once)
18. Who was the first employee hired?



## Solutions

My solutions are in the `*.awk` files in this repository.  Feel free to use them for hints.  You can run them with:

```bash
awk -f <file>.awk payroll.tsv
```

They are also detailed in the [Slides](https://raw.githubusercontent.com/FreedomBen/awk-hack-the-planet/master/Slides%20for%20Awk-%20Hack%20the%20planet%5B's%20text%5D.pdf)
at the end of the deck.
