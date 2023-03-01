print("hello CDWS team")
import pandas as pd #pandas 0.25
from pytrends.request import TrendReq
from pytrends.request import TrendReq

pytrends = TrendReq(hl='en-US', tz=360)
pytrends.interest_by_region(resolution='REGION')
pytrends.build_payload(kw_list=['pizza', 'bagel'], timeframe=['2022-09-04 2022-09-10', '2022-09-18 2022-09-24'])
x = pytrends.multirange_interest_over_time()

print(x)
print('hi')