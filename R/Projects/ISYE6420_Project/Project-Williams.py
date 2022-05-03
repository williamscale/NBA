# ISYE 6420: Project
# Author: Cale Williams
# Last Updated: 04/19/2022

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pymc as pm
from pymc.math import exp, dot
import arviz as az

def main():

    # Read in data.
    data = pd.read_excel(r'.\Data\DMurray\DMurray_PIE.xlsx')

    # Convert game outcome to binary representation.
    # Win = 1, Loss = 0.
    data['Outcome'] = data['W/L'].str[0]
    data['Outcome'].replace(to_replace = ['W', 'L'],
        value = [1, 0],
        inplace = True)

    # Split data into training and test sets.
    train = data.sample(frac = 0.8,
        random_state = 55,
        ignore_index = False)
    test = data.drop(train.index)

    # Ensure split was done correctly.
    # (Using these indices in R frequentist linear regression.)
    assert len(train) + len(test) == len(data), \
        'Dataset split done incorrectly.'
    assert train['G'].isin(test['G']).value_counts()[False] == len(train), \
        'Datasets are overlapping.'

    # Create predictor array.
    x = train[['PIE']].to_numpy()

    # Include intercept.
    x = np.concatenate((np.ones(shape = (x.shape[0], 1)), x),
        axis = 1)

    # Create response array.
    y = train['Outcome'].to_numpy()

    # Create array to predict on.
    x_pred = test[['PIE']].to_numpy()
    x_pred = np.concatenate((np.ones(shape = (x_pred.shape[0], 1)), x_pred),
    	axis = 1)

    with pm.Model() as m_bayes:

    	# Create data variables.
        x_data = pm.Data('x_data',
            value = x,
            mutable = True)
        y_data = pm.Data('y_data',
            value = y,
            mutable = False)

      	# Create regression coefficient priors.
        coef = pm.Normal('beta',
            mu = np.array([-0.916, 1]),
            sigma = np.array([10, 10]),
            shape = x.shape[1])

        # Calculate probability of success.
        p = dot(x_data, coef)


        likelihood = pm.Bernoulli('y',
        	logit_p = p,
            observed = y_data)

        trace = pm.sample(
            draws = 50000,
            chains = 4,
            tune = 2000,
            cores = 4,
            init = 'jitter+adapt_diag',
            random_seed = 1,
            return_inferencedata = True, )

        # Print and save posterior summary.
        post = az.summary(trace,
        	hdi_prob = 0.95)
        print(post)
        post.to_csv('post.csv')

        # Plot trace and density.
        plt.style.use('Solarize_Light2')
        az.plot_trace(trace)
        plt.show()
        
        # Predict on test set.
        # Print and save predictions.
        pm.set_data({"x_data": x_pred})
        post_pred = pm.sample_posterior_predictive(trace)
        pred = az.summary(post_pred,
        	hdi_prob = 0.95)
        print(pred)
        pred.to_csv('predictions.csv')

        # Save trace file to plot in R.
        trace.to_netcdf('trace.nc')

if __name__ == "__main__":
    main()
