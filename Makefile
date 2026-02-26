CHALLENGES := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18
DATA := payroll.tsv

# How to run each challenge (15 is special)
define run_challenge
$(if $(filter 15,$(1)),bash 15-awk.sh,awk -f $(1).awk $(DATA))
endef

.PHONY: test test-server update-expected quiz $(addprefix test-,$(CHALLENGES))

test:
	@pass=0; fail=0; failures=""; \
	for n in $(CHALLENGES); do \
		expected="expected/$$n.expected"; \
		if [ ! -f "$$expected" ]; then \
			echo "SKIP $$n (no expected output file)"; \
			continue; \
		fi; \
		if [ "$$n" = "15" ]; then \
			actual=$$(bash 15-awk.sh 2>&1); \
		else \
			actual=$$(awk -f $$n.awk $(DATA) 2>&1); \
		fi; \
		if printf '%s\n' "$$actual" | diff -u "$$expected" - > /dev/null 2>&1; then \
			echo "PASS $$n"; \
			pass=$$((pass + 1)); \
		else \
			echo "FAIL $$n"; \
			printf '%s\n' "$$actual" | diff -u "$$expected" -; \
			fail=$$((fail + 1)); \
			failures="$$failures $$n"; \
		fi; \
	done; \
	echo ""; \
	total=$$((pass + fail)); \
	echo "$$pass/$$total tests passed"; \
	if [ $$fail -gt 0 ]; then \
		echo "Failures:$$failures"; \
		exit 1; \
	fi

test-server:
	@pass=0; fail=0; \
	./server.sh 18080 & SERVER_PID=$$!; \
	trap "kill $$SERVER_PID 2>/dev/null; wait $$SERVER_PID 2>/dev/null" EXIT; \
	ready=0; \
	for i in 1 2 3 4 5 6 7 8 9 10; do \
		if curl -s -o /dev/null http://localhost:18080/ 2>/dev/null; then \
			ready=1; break; \
		fi; \
		sleep 0.5; \
	done; \
	if [ "$$ready" -ne 1 ]; then \
		echo "FAIL: server did not start within 5 seconds"; \
		exit 1; \
	fi; \
	if curl -s http://localhost:18080/ | grep -q "Payroll API"; then \
		echo "PASS / (HTML index)"; pass=$$((pass + 1)); \
	else \
		echo "FAIL / (HTML index)"; fail=$$((fail + 1)); \
	fi; \
	count=$$(curl -s http://localhost:18080/api/employees | grep -o '"firstName"' | wc -l); \
	if [ "$$count" -eq 4513 ]; then \
		echo "PASS /api/employees ($$count records)"; pass=$$((pass + 1)); \
	else \
		echo "FAIL /api/employees (expected 4513, got $$count)"; fail=$$((fail + 1)); \
	fi; \
	if curl -s http://localhost:18080/api/offices | grep -q '"Springfield"'; then \
		echo "PASS /api/offices"; pass=$$((pass + 1)); \
	else \
		echo "FAIL /api/offices"; fail=$$((fail + 1)); \
	fi; \
	if curl -s http://localhost:18080/api/stats | grep -q '"totalEmployees":4513'; then \
		echo "PASS /api/stats"; pass=$$((pass + 1)); \
	else \
		echo "FAIL /api/stats"; fail=$$((fail + 1)); \
	fi; \
	if curl -s http://localhost:18080/api/info | grep -q '"pid"'; then \
		echo "PASS /api/info"; pass=$$((pass + 1)); \
	else \
		echo "FAIL /api/info"; fail=$$((fail + 1)); \
	fi; \
	status=$$(curl -s -o /dev/null -w '%{http_code}' http://localhost:18080/nonexistent); \
	if [ "$$status" = "404" ]; then \
		echo "PASS /nonexistent (404)"; pass=$$((pass + 1)); \
	else \
		echo "FAIL /nonexistent (expected 404, got $$status)"; fail=$$((fail + 1)); \
	fi; \
	echo ""; \
	echo "$$pass/6 server tests passed"; \
	kill $$SERVER_PID 2>/dev/null; wait $$SERVER_PID 2>/dev/null; \
	trap - EXIT; \
	if [ $$fail -gt 0 ]; then exit 1; fi

define make_test_rule
test-$(1):
	@expected="expected/$(1).expected"; \
	if [ ! -f "$$$$expected" ]; then \
		echo "SKIP $(1) (no expected output file)"; \
		exit 0; \
	fi; \
	if [ "$(1)" = "15" ]; then \
		actual=$$$$(bash 15-awk.sh 2>&1); \
	else \
		actual=$$$$(awk -f $(1).awk $(DATA) 2>&1); \
	fi; \
	if printf '%s\n' "$$$$actual" | diff -u "$$$$expected" - > /dev/null 2>&1; then \
		echo "PASS $(1)"; \
	else \
		echo "FAIL $(1)"; \
		printf '%s\n' "$$$$actual" | diff -u "$$$$expected" -; \
		exit 1; \
	fi
endef

$(foreach n,$(CHALLENGES),$(eval $(call make_test_rule,$(n))))

update-expected:
	@mkdir -p expected
	@for n in $(CHALLENGES); do \
		echo "Generating expected/$$n.expected"; \
		if [ "$$n" = "15" ]; then \
			bash 15-awk.sh > expected/$$n.expected 2>&1; \
		else \
			awk -f $$n.awk $(DATA) > expected/$$n.expected 2>&1; \
		fi; \
	done
	@echo "Done. All expected output files updated."

quiz:
	@bash quiz.sh
