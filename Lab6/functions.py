from scipy.stats import t, chi2, norm
import numpy as np


def calculate_confidence_intervals_normal(sample, alpha=0.05):
    n = len(sample)
    x_bar = np.mean(sample)
    s = np.std(sample, ddof=1)  # несмещенное стандартное отклонение

    # Доверительный интервал для математического ожидания m
    t_crit = t.ppf(1 - alpha / 2, df=n - 1)
    m_lower = x_bar - (s * t_crit) / np.sqrt(n - 1)
    m_upper = x_bar + (s * t_crit) / np.sqrt(n - 1)

    # Доверительный интервал для среднего квадратического отклонения sigma
    chi2_lower = chi2.ppf(alpha / 2, df=n - 1)
    chi2_upper = chi2.ppf(1 - alpha / 2, df=n - 1)
    sigma_lower = s * np.sqrt(n) / np.sqrt(chi2_upper)
    sigma_upper = s * np.sqrt(n) / np.sqrt(chi2_lower)

    return (m_lower, m_upper), (sigma_lower, sigma_upper)


def calculate_confidence_intervals_asymptotic(sample, alpha=0.05):
    n = len(sample)
    x_bar = np.mean(sample)
    s = np.std(sample, ddof=1)

    # Доверительный интервал для математического ожидания m (асимптотический)
    u_crit = norm.ppf(1 - alpha / 2)
    m_lower = x_bar - (s * u_crit) / np.sqrt(n)
    m_upper = x_bar + (s * u_crit) / np.sqrt(n)

    # Доверительный интервал для среднего квадратического отклонения sigma (асимптотический)
    m4 = np.mean((sample - x_bar) ** 4)
    e = m4 / (s ** 4) - 3  # выборочный эксцесс
    U = u_crit * np.sqrt((e + 2) / n)

    sigma_lower = s * (1 + U) ** (-0.5)
    sigma_upper = s * (1 - U) ** (-0.5)

    return (m_lower, m_upper), (sigma_lower, sigma_upper)


def compute_twin(m_lower, m_upper, sigma_lower, sigma_upper):
    # Используем нижнюю границу сигмы для более узкого интервала
    x_inner_lower = m_lower + sigma_lower
    x_inner_upper = m_upper - sigma_lower

    # Используем верхнюю границу сигмы для более широкого интервала
    x_outer_lower = m_lower - sigma_upper
    x_outer_upper = m_upper + sigma_upper

    return (x_inner_lower, x_inner_upper), (x_outer_lower, x_outer_upper)
