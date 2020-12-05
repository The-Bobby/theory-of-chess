#!/usr/bin/env bash
set -e

repo_root="$(readlink -f "$(dirname "$(dirname "$0")")")"

CHESSBOARDS_IN_A_ROW="${1:-4}"
SCALEBOX_WIDTH="$(bc -l <<< "2.8/${CHESSBOARDS_IN_A_ROW}" | head -c 4)"
MINIPAGE_WIDTH="$(bc -l <<< "1/${CHESSBOARDS_IN_A_ROW} - 0.025" | head -c 4)"

{
	counter=0
	for opening in "${repo_root}"/src/*-o-*; do
		#if ! (( counter % CHESSBOARDS_IN_A_ROW )); then
		#  	echo "\begin{figure}[H]"
		# fi
		if ! grep -q '@' "$opening"; then
			continue
		fi
		fen="$(awk -F '@' '/@/ {print $2}' "${opening}")"
		cat \
			"${repo_root}/tools/converter-head.txt" \
			"${opening}" \
			"${repo_root}/tools/converter-tail.txt" | grep -v 'PGN' | sed -r "s@FEN_BOARD@${fen}@g"
		counter=$((counter+1))
		if ! (( counter % CHESSBOARDS_IN_A_ROW )); then
			#echo ""
			echo "\newline"
			#echo ""
		else
			echo "\hspace{5mm}"
		fi
	done

	if (( counter % CHESSBOARDS_IN_A_ROW )); then
		echo ""
	fi
} | sed -r \
	-e "s@SCALEBOX_WIDTH@${SCALEBOX_WIDTH}@g" \
	-e "s@MINIPAGE_WIDTH@${MINIPAGE_WIDTH}@g" > "${repo_root}/src/open.tex"
