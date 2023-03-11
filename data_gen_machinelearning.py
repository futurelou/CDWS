
import pandas as pd
from sodapy import Socrata
import numpy as np
import xgboost as xgb


client = Socrata("data.cdc.gov", None)

results = client.get("n8mc-b4w4", limit=1000000)

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)

df = results_df.sample(200000)
# turning label to binary
df['current_status'] =df.current_status.replace(to_replace=['Probable Case', 'Laboratory-confirmed case'], value=[0, 1])

#  filling na
df['ethnicity'] = df['ethnicity'].fillna('Unknown')
df['race'] = df['race'].fillna('Unknown')
df['sex'] = df['sex'].fillna('Unknown')
df['underlying_conditions_yn'] = df['underlying_conditions_yn'].fillna('No')
df['death_yn'] = df['death_yn'].fillna('Unknown')

#saving label to join back
ylabel = df['current_status']
# removing case positive specimen interval and onset
df = df.drop('case_onset_interval', axis=1)
df = df.drop('case_positive_specimen', axis=1)
df = df.drop('current_status', axis=1)
df = df.drop('case_month', axis=1)
# correctly coding each column

#df = pd.get_dummies(df)
df['current_status'] = ylabel


df.to_csv('df.csv')










