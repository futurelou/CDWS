
import pandas as pd
from sodapy import Socrata
import numpy as np
import xgboost as xgb

# use library socrate to connect to cdc api
client = Socrata("data.cdc.gov", None)

# grab a million rows from the dataset
results = client.get("n8mc-b4w4", limit=1000000)

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)

# randomly sample twenty thousand rows from the million
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

# send this to a csv
df.to_csv('df.csv')










