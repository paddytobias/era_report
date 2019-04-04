cd /home/ubuntu/era_report/R/
echo "$date: begin report script" >> ../log.txt
/usr/bin/Rscript era_report.R
echo "$date: finish report script" >> ../log.txt

