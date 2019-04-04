cd /home/ubuntu/era_report/R/
echo "Begin report script"  >> ../log.txt
echo date  >> ../log.txt
echo "----------"
/usr/bin/Rscript era_report.R
echo date  >> ../log.txt
echo "Finish report script" >> ../log.txt

