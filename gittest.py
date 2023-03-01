import pandas as pd
from pytrends.request import TrendReq
import plotly.express as px
pytrend = TrendReq()

pytrend.build_payload(kw_list=['Cold Symptoms', 'Covid Symptoms', 'Flu Symptoms'],  geo='US')

df = pytrend.interest_over_time()

df = df.reset_index()
print(df)

fig = px.line(df, x='date', y=['Covid Symptoms', 'Cold Symptoms', 'Flu Symptoms'])
fig.show()