#!/usr/bin/env bash
# server.sh — A GAWK-powered JSON API serving payroll data
#
# Usage: ./server.sh [PORT]   (default: 8080)
#
# Demonstrates GAWK networking (/inet/tcp), associative arrays,
# getline file I/O, and PROCINFO — all without @load extensions.

PORT="${1:-8080}"

exec gawk -v port="$PORT" '
#-----------------------------------------------------------------------
# Helper: escape backslashes and double-quotes for JSON strings
#-----------------------------------------------------------------------
function json_escape(s) {
    gsub(/\\/, "\\\\", s)
    gsub(/"/, "\\\"", s)
    return s
}

#-----------------------------------------------------------------------
# Helper: send a complete HTTP response (headers + body)
#-----------------------------------------------------------------------
function send_response(code, reason, ctype, body,    len) {
    len = length(body)
    printf "HTTP/1.0 %d %s\r\n", code, reason |& S
    printf "Content-Type: %s\r\n", ctype          |& S
    printf "Content-Length: %d\r\n", len           |& S
    printf "Connection: close\r\n"                 |& S
    printf "\r\n"                                  |& S
    printf "%s", body                              |& S
}

#-----------------------------------------------------------------------
# Helper: send HTTP headers only (no Content-Length — for streaming)
#-----------------------------------------------------------------------
function send_headers(code, reason, ctype) {
    printf "HTTP/1.0 %d %s\r\n", code, reason |& S
    printf "Content-Type: %s\r\n", ctype       |& S
    printf "Connection: close\r\n"             |& S
    printf "\r\n"                              |& S
}

#-----------------------------------------------------------------------
# Helper: log a request to stderr (avoids \r\n ORS in log output)
#-----------------------------------------------------------------------
function log_request(method, path, status) {
    printf "%s %s -> %d\n", method, path, status > "/dev/stderr"
}

#-----------------------------------------------------------------------
# Route: GET / — HTML index listing available endpoints
#-----------------------------------------------------------------------
function handle_index(    body) {
    body = "<html><head><title>Payroll API</title></head><body>"
    body = body "<h1>Payroll API</h1><ul>"
    body = body "<li><a href=\"/api/employees\">/api/employees</a> — All employees (JSON)</li>"
    body = body "<li><a href=\"/api/offices\">/api/offices</a> — Office headcounts (JSON)</li>"
    body = body "<li><a href=\"/api/stats\">/api/stats</a> — Aggregate statistics (JSON)</li>"
    body = body "<li><a href=\"/api/info\">/api/info</a> — Server process info (JSON)</li>"
    body = body "</ul></body></html>"
    send_response(200, "OK", "text/html", body)
    log_request("GET", "/", 200)
}

#-----------------------------------------------------------------------
# Route: GET /api/employees — stream JSON array of all employees
#-----------------------------------------------------------------------
function handle_employees(    i) {
    send_headers(200, "OK", "application/json")
    printf "[" |& S
    for (i = 1; i <= num_employees; i++) {
        if (i > 1) printf "," |& S
        printf "{\"firstName\":\"%s\",\"lastName\":\"%s\",\"hourlyWage\":%.2f,\"hoursWorked\":%d,\"office\":\"%s\",\"title\":\"%s\",\"startDate\":\"%s\"}", \
            json_escape(first_names[i]), \
            json_escape(last_names[i]), \
            wages[i], hours[i], \
            json_escape(offices[i]), \
            json_escape(titles[i]), \
            json_escape(start_dates[i]) |& S
    }
    printf "]" |& S
    log_request("GET", "/api/employees", 200)
}

#-----------------------------------------------------------------------
# Route: GET /api/offices — JSON object of office -> employee count
#-----------------------------------------------------------------------
function handle_offices(    body, sep, office) {
    body = "{"
    sep = ""
    for (office in office_counts) {
        body = body sep sprintf("\"%s\":%d", json_escape(office), office_counts[office])
        sep = ","
    }
    body = body "}"
    send_response(200, "OK", "application/json", body)
    log_request("GET", "/api/offices", 200)
}

#-----------------------------------------------------------------------
# Route: GET /api/stats — aggregate payroll statistics
#-----------------------------------------------------------------------
function handle_stats(    body) {
    body = sprintf("{\"totalEmployees\":%d,\"averageWage\":%.2f,\"minWage\":%.2f,\"maxWage\":%.2f,\"totalHoursWorked\":%d}", \
        num_employees, avg_wage, min_wage, max_wage, total_hours)
    send_response(200, "OK", "application/json", body)
    log_request("GET", "/api/stats", 200)
}

#-----------------------------------------------------------------------
# Route: GET /api/info — GAWK process info from PROCINFO
#-----------------------------------------------------------------------
function handle_info(    body) {
    body = sprintf("{\"pid\":%d,\"ppid\":%d,\"uid\":%d,\"gid\":%d,\"version\":\"%s\"}", \
        PROCINFO["pid"], PROCINFO["ppid"], \
        PROCINFO["uid"], PROCINFO["gid"], \
        json_escape(PROCINFO["version"]))
    send_response(200, "OK", "application/json", body)
    log_request("GET", "/api/info", 200)
}

#-----------------------------------------------------------------------
# Route: anything else — 404 Not Found
#-----------------------------------------------------------------------
function handle_404(path,    body) {
    body = sprintf("{\"error\":\"Not Found\",\"path\":\"%s\"}", json_escape(path))
    send_response(404, "Not Found", "application/json", body)
    log_request("GET", path, 404)
}

#-----------------------------------------------------------------------
# BEGIN: load data, then enter HTTP request loop
#-----------------------------------------------------------------------
BEGIN {
    # --- Phase 1: Load payroll.tsv (RS is still default \n) ----------
    num_employees = 0
    min_wage = -1
    max_wage = 0
    total_wages = 0
    total_hours = 0

    while ((getline line < "payroll.tsv") > 0) {
        # Skip header row
        if (line ~ /^FirstName/) continue

        split(line, fields, "\t")
        num_employees++
        i = num_employees

        first_names[i] = fields[1]
        last_names[i]  = fields[2]
        wages[i]       = fields[3] + 0
        hours[i]       = fields[4] + 0
        offices[i]     = fields[5]
        titles[i]      = fields[6]
        start_dates[i] = fields[7]

        total_wages += wages[i]
        total_hours += hours[i]

        if (min_wage < 0 || wages[i] < min_wage) min_wage = wages[i]
        if (wages[i] > max_wage) max_wage = wages[i]

        office_counts[offices[i]]++
    }
    close("payroll.tsv")

    avg_wage = (num_employees > 0) ? total_wages / num_employees : 0

    printf "Loaded %d employees from payroll.tsv\n", num_employees > "/dev/stderr"

    # --- Phase 2: HTTP server mode -----------------------------------
    RS = ORS = "\r\n"
    S = "/inet/tcp/" port "/0/0"

    printf "Listening on port %s\n", port > "/dev/stderr"

    while (1) {
        # Read the request line and headers
        method = ""
        path = ""
        while ((S |& getline line) > 0) {
            # Parse the request line (first non-empty line)
            if (method == "" && line ~ /^[A-Z]+ /) {
                split(line, req, " ")
                method = req[1]
                path   = req[2]
            }
            # Empty line signals end of headers
            if (line == "") break
        }

        # Route the request
        if (path == "/") {
            handle_index()
        } else if (path == "/api/employees") {
            handle_employees()
        } else if (path == "/api/offices") {
            handle_offices()
        } else if (path == "/api/stats") {
            handle_stats()
        } else if (path == "/api/info") {
            handle_info()
        } else {
            handle_404(path)
        }

        close(S)
    }
}
'
