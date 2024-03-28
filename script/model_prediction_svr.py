# predict with a final model
# python3 model_prediction_linr.py Matsushita_PHBH_BLOSUM_pred.csv Matsushita_PHBH_compound7_BLOSUM

import sys
import pickle
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR 

def load_data(infile):
    with open(infile) as f:
        ncol = len(f.readline().split(','))
    A = np.asarray( np.loadtxt(infile, skiprows=1, usecols=range(1,ncol), delimiter=',') )
    X = A
    return X


RANDOM_STATE=0
infile = sys.argv[1]
insuf = sys.argv[2]

print('load', flush=True)
X = load_data(infile)

print('scale', flush=True)
scaler = pickle.load(open(insuf + '.scaler.pickle', 'rb'))
X = scaler.transform(X)

print('predict', flush=True)
model = pickle.load(open(insuf + '.model.pickle', 'rb'))
y_pred = model.predict(X)

print('y_pred', flush=True)
for i in range(len(y_pred)):
    print(str(y_pred[i]))
