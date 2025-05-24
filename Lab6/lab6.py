import numpy as np
import functions as my

# Пример использования
np.random.seed(1)  # Для воспроизводимости результатов

sample_size = [20, 100]

for size in sample_size:
    # Генерация выборки
    sample = np.random.normal(0, 1, size)

    # Вычисление доверительных интервалов для нормального распределения
    (m_low_normal, m_upp_normal), (sigma_low_normal, sigma_upp_normal) = my.calculate_confidence_intervals_normal(
        sample)

    # Вычисление доверительных интервалов для произвольного распределения (асимптотический подход)
    (m_low_asymp, m_upp_asymp), (sigma_low_asymp, sigma_upp_asymp) = my.calculate_confidence_intervals_asymptotic(
        sample)

    # Вычисление твинов для нормального распределения
    x_inner_normal, x_outer_normal = my.compute_twin(m_low_normal, m_upp_normal,
                                                     sigma_low_normal, sigma_upp_normal)

    # Вычисление твинов для асимптотического подхода
    x_inner_asymp, x_outer_asymp = my.compute_twin(m_low_asymp, m_upp_asymp,
                                                   sigma_low_asymp, sigma_upp_asymp)

    # Вывод результатов
    print("Доверительные интервалы для параметров нормального распределения:")
    print(
        f"n = {size}: m in [{m_low_normal:.2f}, {m_upp_normal:.2f}], σ in [{sigma_low_normal:.2f}, {sigma_upp_normal:.2f}]")
    print("\nДоверительные интервалы для параметров произвольного распределения (асимптотический подход):")
    print(
        f"n = {size}: m in [{m_low_asymp:.2f}, {m_upp_asymp:.2f}], σ in [{sigma_low_asymp:.2f}, {sigma_upp_asymp:.2f}]")

    print("\nТвины для нормального распределения:")
    print(
        f"n = {size}: x_inner in [{x_inner_normal[0]:.2f}, {x_inner_normal[1]:.2f}], x_outer in [{x_outer_normal[0]:.2f}, {x_outer_normal[1]:.2f}]")

    print("\nТвины для асимптотического подхода:")
    print(
        f"n = {size}: x_inner in [{x_inner_asymp[0]:.2f}, {x_inner_asymp[1]:.2f}], x_outer in [{x_outer_asymp[0]:.2f}, {x_outer_asymp[1]:.2f}]")