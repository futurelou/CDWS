import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier
from sklearn.model_selection import GridSearchCV
import xgboost as xgb
from sklearn.metrics import accuracy_score, f1_score

df = pd.read_csv(r'https://raw.githubusercontent.com/CovidWastewaterDetectionSystem/CDWS/main/df.csv',index_col=0)

cats = df.select_dtypes(exclude=np.number).columns.tolist()

for col in cats:
    df[col] = df[col].astype('category')


#splitting the data


X = df.drop(['current_status','state_fips_code','county_fips_code','res_state', 'res_county','death_yn','process','icu_yn'], axis=1)
y = df['current_status']

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=66)

xgtrain = xgb.DMatrix(X_train, label= y_train,enable_categorical=True)


param = {'max_depth': 1,
         'eta': 0.01,
         'objective': 'binary:logistic',
         'eval_metric': 'error',
         'nthread': 4}

model = xgb.train(param, xgtrain, 400)


def predict1(age_group, sex, race, ethnicity, exposure_yn,symptom_status,hosp_yn, underlying_conditions_yn):

    Data ={ 'age_group':  [age_group],
     'sex': [sex],
    'race':[race],
   'ethnicity': [ethnicity],
   'exposure_yn': [exposure_yn],
  'symptom_status':  [symptom_status],
   'hosp_yn': [hosp_yn],
'underlying_conditions_yn':[underlying_conditions_yn]}


    test = pd.DataFrame(Data)
    print(type(test))
    cats = test.select_dtypes(exclude=np.number).columns.tolist()

    for col in cats:
        test[col] = test[col].astype('category')

    xgtest = xgb.DMatrix(test, enable_categorical=True)

    preds = model.predict(xgtest)

    for i in range(len(preds)):
        if i<0.5:
            preds[i]= "You do not have covid"
        elif i>0.5:
            preds[i]= "you have covid"



    return preds



