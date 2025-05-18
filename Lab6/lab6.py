import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt

def confidence_interval_mean_normal(x, alpha=0.05):
    n = len(x)
    x_mean = np.mean(x)
    s = np.std(x, ddof=1)
    t = stats.t.ppf(1 - alpha/2, df=n-1)
    margin_error = t * s / np.sqrt(n)
    return (x_mean - margin_error, x_mean + margin_error)

def confidence_interval_sigma_normal(x, alpha=0.05):
    n = len(x)
    s = np.std(x, ddof=1)
    chi2_lower = stats.chi2.ppf(alpha/2, df=n-1)
    chi2_upper = stats.chi2.ppf(1 - alpha/2, df=n-1)
    lower = s * np.sqrt(n-1) / np.sqrt(chi2_upper)
    upper = s * np.sqrt(n-1) / np.sqrt(chi2_lower)
    return (lower, upper)

def confidence_interval_mean_asymp(x, alpha=0.05):
    n = len(x)
    x_mean = np.mean(x)
    s = np.std(x, ddof=1)
    u = stats.norm.ppf(1 - alpha/2)
    margin_error = u * s / np.sqrt(n)
    return (x_mean - margin_error, x_mean + margin_error)

def confidence_interval_sigma_asymp(x, alpha=0.05):
    n = len(x)
    s = np.std(x, ddof=1)
    m4 = np.mean((x - np.mean(x))**4)
    e = m4 / (s**4) - 3
    u = stats.norm.ppf(1 - alpha/2)
    U = u * np.sqrt((e + 2) / n)
    lower = s * (1 + U)**(-0.5)
    upper = s * (1 - U)**(-0.5)
    return (lower, upper)

def print_intervals(n, x):
    print(f"\nSample size n = {n}")
    
    m_normal = confidence_interval_mean_normal(x)
    sigma_normal = confidence_interval_sigma_normal(x)
    
    m_asymp = confidence_interval_mean_asymp(x)
    sigma_asymp = confidence_interval_sigma_asymp(x)
    
    print(f"Normal distribution assumption:")
    print(f"  Mean: {m_normal[0]:.2f} < m < {m_normal[1]:.2f}")
    print(f"  Sigma: {sigma_normal[0]:.2f} < sigma < {sigma_normal[1]:.2f}")
    
    print(f"Asymptotic approach:")
    print(f"  Mean: {m_asymp[0]:.2f} < m < {m_asymp[1]:.2f}")
    print(f"  Sigma: {sigma_asymp[0]:.2f} < sigma < {sigma_asymp[1]:.2f}")
np.random.seed(42)  
n1 = 20
sample1 = np.random.normal(loc=0, scale=1, size=n1)
n2 = 100
sample2 = np.random.normal(loc=0, scale=1, size=n2)

print_intervals(n1, sample1)
print_intervals(n2, sample2)