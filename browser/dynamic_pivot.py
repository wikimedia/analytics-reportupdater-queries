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
		date, category, value = row
		dates.add(date)
		try:
			number = int(value)
		except:
			number = float(value)
		finally:
			pivoted[category][date] += number

categories = sorted(pivoted.keys())
print header[0] + '\t' + '\t'.join(categories)
for date in sorted(dates):
	category_row = [str(pivoted[c][date]) for c in categories]
	print date + '\t' + '\t'.join(category_row)
