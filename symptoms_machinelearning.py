
import pandas as pd
from sodapy import Socrata
import numpy as np
import xgboost as xgb
from sklearn.metrics import mean_squared_error

client = Socrata("data.cdc.gov", None)

results = client.get("n8mc-b4w4", limit=1000)

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)

df = results_df.sample(200)
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


cats = df.select_dtypes(exclude=np.number).columns.tolist()

for col in cats:
    df[col] = df[col].astype('category')


train, validate, test = np.split(df.sample(frac=1, random_state=42), [int(.6 * len(df)), int(.8 * len(df))])
#splitting the data in to a 60, 20, 20 split
y_train = train['current_status']
y_test = test['current_status']


x_train = train.drop('current_status', axis=1)
x_test = test.drop('current_status', axis=1)
validate = validate.drop('current_status', axis=1)



dtrain_reg = xgb.DMatrix(x_train, y_train, enable_categorical=True)

dtest_reg = xgb.DMatrix(x_test, y_test, enable_categorical=True)
#current status is the label


params = {"objective": "binary:logistic"}

n = 100

evals = [(dtest_reg, "validation"), (dtrain_reg, "train")]

model = xgb.train(

   params=params,

   dtrain=dtrain_reg,

   num_boost_round=n,

    evals=evals,

    verbose_eval=10


)






