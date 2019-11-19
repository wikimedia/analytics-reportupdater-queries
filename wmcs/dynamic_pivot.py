import sys
import csv
from collections import defaultdict

reader = csv.reader(sys.stdin, delimiter='\t')
header = None
dates = set([])
pivoted = defaultdict(lambda: defaultdict(lambda: 0))

for row in reader:
	if header is None:
		header = row
	else:
		date, wiki, percent = row
		dates.add(date)
		try:
			number = int(percent)
		except:
			number = float(percent)
		finally:
			pivoted[wiki][date] += number

wikis = sorted(pivoted.keys())
print header[0] + '\t' + '\t'.join(wikis)
for date in sorted(dates):
	wiki_row = [str(pivoted[c][date]) for c in wikis]
	print date + '\t' + '\t'.join(wiki_row)
