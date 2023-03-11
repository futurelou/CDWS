import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier
from sklearn.model_selection import GridSearchCV
import xgboost as xgb

df = pd.read_csv(r'C:\Users\louie\OneDrive\CDWS\df.csv',index_col=0)

cats = df.select_dtypes(exclude=np.number).columns.tolist()

for col in cats:
    df[col] = df[col].astype('category')


#splitting the data


X = df.drop(['current_status','state_fips_code','county_fips_code'], axis=1)
y = df['current_status']

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=66)

xgtrain = xgb.DMatrix(X_train, label= y_train,enable_categorical=True)
xgtest = xgb.DMatrix(X_test ,enable_categorical=True)

