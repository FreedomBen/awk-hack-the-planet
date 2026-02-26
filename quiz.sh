#!/usr/bin/env bash
#
# Interactive CLI quiz for Awk: Hack the Planet
# Presents each challenge, accepts AWK code, and checks against expected output.

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve script directory so quiz works from any working directory
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROGRESS_FILE=".quiz-progress"
DATA="payroll.tsv"
CHALLENGES=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18)

# ---------------------------------------------------------------------------
# Terminal colours (graceful fallback when not a tty)
# ---------------------------------------------------------------------------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    BOLD=$(tput bold)
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    BOLD="" GREEN="" RED="" YELLOW="" CYAN="" RESET=""
fi

# ---------------------------------------------------------------------------
# Challenge metadata
# ---------------------------------------------------------------------------
declare -A TIER PROMPT

TIER[01]="Easy"           ; PROMPT[01]="How much money per hour does the janitor make?"
TIER[02]="Easy"           ; PROMPT[02]='What is the name of the CEO?  Format like "LastName, FirstName"?'
TIER[03]="Easy"           ; PROMPT[03]="Which employees were hired on April 16, 1993? (Print the list)"
TIER[04]="Easy"           ; PROMPT[04]="Which employee works in the Springfield office?"

TIER[05]="A little harder"; PROMPT[05]="How many mechanical engineers work here?"
TIER[06]="A little harder"; PROMPT[06]="How many people from the Portwood family work here?"
TIER[07]="A little harder"; PROMPT[07]="Are there any employees with identical first & last names? (IOW, the first name is the same as the last name. e.g. Linus Torvalds is not identical, Johnson Johnson is identical)"

TIER[08]="Gotta think a bit"; PROMPT[08]='Print each column header, along with the column number. E.g. The LastName column is the second column, so print "2 - LastName"'
TIER[09]="Gotta think a bit"; PROMPT[09]="How much money per hour does the Seattle office cost to run? (IOW, how much total per hour does it cost to pay all employees who work out of the Seattle office)"
TIER[10]="Gotta think a bit"; PROMPT[10]="How many engineers (of any type) work here?"
TIER[11]="Gotta think a bit"; PROMPT[11]="Who is the highest paid employee?"
TIER[12]="Gotta think a bit"; PROMPT[12]="Who worked the most hours this week?"

TIER[13]="Awk proficient" ; PROMPT[13]="Anonymize the data by removing the first two columns. Print all remaining columns."
TIER[14]="Awk proficient" ; PROMPT[14]="Our client is complaining about the anonymized data from the previous question. They say it is too hard to read. They would like you to add line numbers to the beginning of each line in the output."
TIER[15]="Awk proficient" ; PROMPT[15]="How many different office locations does the company have? (Hint: you may need to pipe through sort/uniq)"
TIER[16]="Awk proficient" ; PROMPT[16]="What is the average (mean) wage of all employees? What about the median (extra credit)?"
TIER[17]="Awk proficient" ; PROMPT[17]="Are there any duplicate entries? (Same names appearing on payroll more than once)"
TIER[18]="Awk proficient" ; PROMPT[18]="Who was the first employee hired?"

# ---------------------------------------------------------------------------
# Progress helpers
# ---------------------------------------------------------------------------
load_progress() {
    declare -gA COMPLETED
    if [ -f "$PROGRESS_FILE" ]; then
        while IFS= read -r line; do
            COMPLETED["$line"]=1
        done < "$PROGRESS_FILE"
    fi
}

save_progress() {
    : > "$PROGRESS_FILE"
    for n in "${CHALLENGES[@]}"; do
        if [ "${COMPLETED[$n]:-}" = "1" ]; then
            echo "$n" >> "$PROGRESS_FILE"
        fi
    done
}

count_completed() {
    local c=0
    for n in "${CHALLENGES[@]}"; do
        [ "${COMPLETED[$n]:-}" = "1" ] && c=$((c + 1))
    done
    echo "$c"
}

first_incomplete() {
    for n in "${CHALLENGES[@]}"; do
        if [ "${COMPLETED[$n]:-}" != "1" ]; then
            echo "$n"
            return
        fi
    done
    echo "01"  # all done, start over
}

# ---------------------------------------------------------------------------
# Ctrl-C trap
# ---------------------------------------------------------------------------
cleanup() {
    echo ""
    echo "${YELLOW}Saving progress and exiting. See you next time!${RESET}"
    save_progress
    exit 0
}
trap cleanup INT

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
if [ ! -f "$DATA" ]; then
    echo "${RED}Error: $DATA not found in $SCRIPT_DIR${RESET}" >&2
    exit 1
fi
if [ ! -d "expected" ]; then
    echo "${RED}Error: expected/ directory not found in $SCRIPT_DIR${RESET}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Welcome
# ---------------------------------------------------------------------------
load_progress
completed=$(count_completed)

echo ""
echo "${BOLD}${CYAN}=== Awk: Hack the Planet — Interactive Quiz ===${RESET}"
echo ""
echo "Payroll data preview (first 5 rows):"
echo "${CYAN}"
head -6 "$DATA" | column -t -s $'\t'
echo "${RESET}"
echo "Progress: ${BOLD}${completed}/18${RESET} challenges completed"
echo ""
echo "Type AWK code to solve each challenge (blank line submits)."
echo "Type ${BOLD}help${RESET} for available commands."
echo ""

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
current=$(first_incomplete)

while true; do
    expected_file="expected/${current}.expected"
    if [ ! -f "$expected_file" ]; then
        echo "${RED}No expected output for challenge $current — skipping.${RESET}"
        # advance to next
        idx=0
        for i in "${!CHALLENGES[@]}"; do
            [ "${CHALLENGES[$i]}" = "$current" ] && idx=$i && break
        done
        next_idx=$(( (idx + 1) % ${#CHALLENGES[@]} ))
        current="${CHALLENGES[$next_idx]}"
        continue
    fi

    # Show challenge
    status=""
    [ "${COMPLETED[$current]:-}" = "1" ] && status=" ${GREEN}[COMPLETED]${RESET}"
    echo "${BOLD}--- Challenge ${current} ---${RESET}  ${YELLOW}[${TIER[$current]}]${RESET}${status}"
    echo "${PROMPT[$current]}"
    if [ "$current" = "15" ]; then
        echo "${CYAN}(This challenge expects a full shell command, not just AWK code)${RESET}"
    fi
    echo ""

    # Read input (multi-line, blank line submits)
    echo "${BOLD}Your answer${RESET} (blank line to submit):"
    input=""
    while IFS= read -r -p "> " line; do
        [ -z "$line" ] && break
        if [ -z "$input" ]; then
            input="$line"
        else
            input="$input"$'\n'"$line"
        fi
    done

    # Handle empty input
    if [ -z "$input" ]; then
        echo "${YELLOW}Empty input — try again or type 'help' for commands.${RESET}"
        echo ""
        continue
    fi

    # ----- Commands -----
    case "$input" in
        help)
            echo ""
            echo "${BOLD}Commands:${RESET}"
            echo "  ${CYAN}skip${RESET}     — skip to the next challenge"
            echo "  ${CYAN}hint${RESET}     — show expected output"
            echo "  ${CYAN}reveal${RESET}   — show the reference solution source"
            echo "  ${CYAN}quit${RESET}|${CYAN}q${RESET}  — save progress and exit"
            echo "  ${CYAN}help${RESET}     — show this message"
            echo "  ${CYAN}1${RESET}–${CYAN}18${RESET}    — jump to a specific challenge"
            echo ""
            continue
            ;;
        skip)
            echo "${YELLOW}Skipping challenge ${current}.${RESET}"
            idx=0
            for i in "${!CHALLENGES[@]}"; do
                [ "${CHALLENGES[$i]}" = "$current" ] && idx=$i && break
            done
            next_idx=$(( (idx + 1) % ${#CHALLENGES[@]} ))
            current="${CHALLENGES[$next_idx]}"
            echo ""
            continue
            ;;
        hint)
            echo ""
            echo "${CYAN}Expected output:${RESET}"
            cat "$expected_file"
            echo ""
            continue
            ;;
        reveal)
            echo ""
            if [ "$current" = "15" ]; then
                sol_file="15-awk.sh"
            else
                sol_file="${current}.awk"
            fi
            if [ -f "$sol_file" ]; then
                echo "${CYAN}Reference solution (${sol_file}):${RESET}"
                cat "$sol_file"
            else
                echo "${RED}Solution file ${sol_file} not found.${RESET}"
            fi
            echo ""
            continue
            ;;
        quit|q)
            save_progress
            echo "${YELLOW}Progress saved. Goodbye!${RESET}"
            exit 0
            ;;
        [0-9]|[0-9][0-9])
            # Jump to a specific challenge
            target=$(printf "%02d" "$input" 2>/dev/null || true)
            found=0
            for n in "${CHALLENGES[@]}"; do
                if [ "$n" = "$target" ]; then
                    found=1
                    break
                fi
            done
            if [ "$found" = "1" ]; then
                current="$target"
                echo ""
                continue
            else
                echo "${RED}Invalid challenge number. Use 1–18.${RESET}"
                echo ""
                continue
            fi
            ;;
    esac

    # ----- Execute user code -----
    tmpfile=$(mktemp /tmp/quiz-awk-XXXXXX.awk)
    # shellcheck disable=SC2064
    trap "rm -f '$tmpfile'; cleanup" INT

    if [ "$current" = "15" ]; then
        # Challenge 15: user provides a full shell command
        actual=$(eval "$input" 2>&1) || true
    else
        echo "$input" > "$tmpfile"
        actual=$(awk -F '\t' -f "$tmpfile" "$DATA" 2>&1) || true
    fi

    rm -f "$tmpfile"
    trap cleanup INT

    # ----- Compare output -----
    diff_output=$(printf '%s\n' "$actual" | diff -u "$expected_file" - 2>&1) || true

    if [ -z "$diff_output" ]; then
        echo ""
        echo "${GREEN}${BOLD}PASS!${RESET} ${GREEN}Challenge ${current} correct.${RESET}"
        COMPLETED["$current"]=1
        save_progress
        completed=$(count_completed)
        echo "Progress: ${BOLD}${completed}/18${RESET}"

        if [ "$completed" -eq 18 ]; then
            echo ""
            echo "${GREEN}${BOLD}Congratulations! You've completed all 18 challenges!${RESET}"
            echo ""
        fi

        # Advance to next challenge
        idx=0
        for i in "${!CHALLENGES[@]}"; do
            [ "${CHALLENGES[$i]}" = "$current" ] && idx=$i && break
        done
        next_idx=$(( (idx + 1) % ${#CHALLENGES[@]} ))
        current="${CHALLENGES[$next_idx]}"
    else
        echo ""
        echo "${RED}${BOLD}FAIL${RESET} ${RED}— output doesn't match expected.${RESET}"
        echo ""
        # Truncate large diffs (avoid piping through head — pipefail + SIGPIPE)
        diff_lines=$(printf '%s\n' "$diff_output" | wc -l)
        if [ "$diff_lines" -gt 40 ]; then
            printf '%s\n' "$diff_output" | head -30 || true
            echo "${YELLOW}... ($diff_lines total lines, truncated — showing first 30)${RESET}"
        else
            printf '%s\n' "$diff_output"
        fi
        echo ""
        echo "Try again, or type ${BOLD}hint${RESET} to see expected output."
    fi

    echo ""
done
