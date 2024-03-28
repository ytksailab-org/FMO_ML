# evaluate a model for model selection
# python3 model_selection_svr.py mse Kadonosono_FLAP_CD22_BLOSUM.csv

import sys
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR
from sklearn.model_selection import cross_validate, cross_val_score, KFold, GridSearchCV
from sklearn.metrics import make_scorer
from scipy.stats import spearmanr, pearsonr

def load_data(infile):
    with open(infile) as f:
        ncol = len(f.readline().split(','))
    A = np.asarray( np.loadtxt(infile, skiprows=1, usecols=range(1,ncol), delimiter=',') )
    X = A[:, 0:ncol-2]
    y = A[:, ncol-2]
    return X, y

def pearsonr_metric(y_true, y_pred):
    r = pearsonr(x=y_true, y=y_pred)
    return r[0] 

def spearmanr_metric(y_true, y_pred):
    r = spearmanr(a=y_true, b=y_pred)
    return r[0] 

def set_scoring(metric):
    if metric == 'r2':
        return 'r2'
    elif metric == 'rmse':
        return 'neg_root_mean_squared_error'
    elif metric == 'pearson':
        return make_scorer(pearsonr_metric)
    elif metric == 'spearman':
        return make_scorer(spearmanr_metric)
    else:
        print('wrong metric', metric)
        exit()


RANDOM_STATE=0
N_SPLITS=5
metric = sys.argv[1]
infile = sys.argv[2]

print('load', flush=True)
scoring = set_scoring(metric)
X, y = load_data(infile)

print('scale', flush=True)
scaler = StandardScaler()
X = scaler.fit_transform(X)

print('cv', flush=True)
model = SVR()
param_grid = {'gamma': [1e-5, 1e-4, 1e-3, 1e-2, 1e-1], 'C': [1e-2, 1e-1, 1e0, 1e1, 1e2], 'epsilon': [1e-4, 1e-3, 1e-2, 1e-1, 1e0]}
inner_cv = KFold(n_splits=N_SPLITS, shuffle=True, random_state=RANDOM_STATE)
outer_cv = KFold(n_splits=N_SPLITS, shuffle=True, random_state=RANDOM_STATE)
inner_model = GridSearchCV(estimator=model, param_grid=param_grid, cv=inner_cv, scoring=scoring, verbose=1)
res = cross_validate(estimator=inner_model, X=X, y=y, cv=outer_cv, scoring=scoring, return_estimator=True, verbose=1)
print('parameters:')
for i in range(N_SPLITS):
    print(res['estimator'][i].best_params_)
print('scores:')
for i in range(N_SPLITS):
    print(res['test_score'][i])
print('mean score:')
print(res['test_score'].mean())

#model = SVR()
#cv = KFold(n_splits=N_SPLITS, shuffle=True, random_state=RANDOM_STATE)
#res = cross_validate(model, X=X, y=y, cv=cv, scoring=scoring, return_estimator=True, verbose=1)
#print('score:', res['test_score'].mean())
#for i in range(N_SPLITS):
#    print(res['estimator'][i].get_params())
