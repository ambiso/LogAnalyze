#!/bin/sh

cargo build --release
rsync "$(cat serverpath)" . -rva
cd logs/
(echo 'Timestamp, Users'; cat $(ls -1 | sort -M) | ../target/release/loganalyze | tail -n+2 | sed 's/\.[0-9]\{6\}//' | sort -k1,2 -u)  > ../out.csv
cd ..
Rscript stat.r
eog '24 hours.png' '72 hours.png' '4 weeks.png' '12 months.png'
echo Done
