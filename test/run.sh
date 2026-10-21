#!/bin/sh
set -eu

TESTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(dirname -- "$TESTDIR")
VIM_BIN=${VIM_BIN:-vim}

RED=''
GREEN=''
RESET=''
if [ -t 1 ]; then
	RED=$(printf '\033[31m')
	GREEN=$(printf '\033[32m')
	RESET=$(printf '\033[0m')
fi

pass() { printf '%s  ok%s  %s\n' "$GREEN" "$RESET" "$1"; }
fail() { printf '%sFAIL%s  %s\n' "$RED" "$RESET" "$1"; }

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT INT TERM
export HOME="$SANDBOX"
REPORT="$SANDBOX/report.txt"
export SUPRAVIM_TEST_REPORT="$REPORT"

total=0
failed=0

for t in "$TESTDIR"/t_*.vim; do
	[ -e "$t" ] || continue

	name=$(basename "$t")
	run="$SANDBOX/$name"
	cp "$TESTDIR/helpers.vim" "$SANDBOX/helpers.vim"
	cat "$t" "$TESTDIR/driver.vim" > "$run"
	rm -f "$REPORT"

	"$VIM_BIN" -N -i NONE -u NONE --not-a-term \
		--cmd "set rtp^=$ROOT" \
		--cmd 'filetype plugin indent on' \
		--cmd 'syntax enable' \
		--cmd 'set backspace=indent,eol,start' \
		--cmd "runtime plugin/auto-pairs.vim" \
		-c "source $run" -c 'qa!' </dev/null >/dev/null 2>&1 || true

	if [ ! -f "$REPORT" ]; then
		failed=$((failed + 1))
		total=$((total + 1))
		fail "$name (le script n'a produit aucun rapport)"
		continue
	fi

	while IFS= read -r line; do
		case "$line" in
		"PASS "*)
			total=$((total + 1))
			pass "${line#PASS }"
			;;
		"FAIL "*)
			total=$((total + 1))
			failed=$((failed + 1))
			fail "${line#FAIL }"
			;;
		*)
			printf '%s\n' "$line"
			;;
		esac
	done < "$REPORT"
done

printf '\n%d tests, %d failed\n' "$total" "$failed"
[ "$failed" -eq 0 ]
