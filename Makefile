CHALLENGES := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18
DATA := payroll.tsv

# How to run each challenge (15 is special)
define run_challenge
$(if $(filter 15,$(1)),bash 15-awk.sh,awk -f $(1).awk $(DATA))
endef

.PHONY: test update-expected $(addprefix test-,$(CHALLENGES))

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
