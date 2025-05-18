import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)
n = 1000
X1 = np.random.normal(0, 0.95, n)
X2 = np.random.normal(1, 1.05, n)

def get_inn(X):
    Q1 = np.percentile(X, 25)
    Q3 = np.percentile(X, 75)
    return (Q1, Q3)

def get_out(X):
    return (np.min(X), np.max(X))

def jaccard(interval1, interval2):
    left = max(interval1[0], interval2[0])
    right = min(interval1[1], interval2[1])
    intersection = max(0, right - left)
    union = max(interval1[1], interval2[1]) - min(interval1[0], interval2[0])
    return intersection / union if union != 0 else 0

a_values = np.linspace(-2, 4, 300)
J_inn = []
J_out = []

for a in a_values:
    shifted_X1 = X1 + a
    inn1 = get_inn(shifted_X1)
    out1 = get_out(shifted_X1)
    inn2 = get_inn(X2)
    out2 = get_out(X2)
    J_inn.append(jaccard(inn1, inn2))
    J_out.append(jaccard(out1, out2))

a_inn = a_values[np.argmax(J_inn)]
a_out = a_values[np.argmax(J_out)]

print(f"Оптимальный сдвиг по внутренней оценке (a_inn): {a_inn:.4f}")
print(f"Оптимальный сдвиг по внешней оценке (a_out): {a_out:.4f}")

plt.figure(figsize=(12, 6))
plt.plot(a_values, J_inn, label='$J_{Inn}(a)$', color='green')
plt.plot(a_values, J_out, label='$J_{Out}(a)$', color='red')
plt.axvline(a_inn, color='green', linestyle='--', label=f'$a_{{Inn}} = {a_inn:.2f}$')
plt.axvline(a_out, color='red', linestyle='--', label=f'$a_{{Out}} = {a_out:.2f}$')
plt.xlabel('Сдвиг $a$')
plt.ylabel('Индекс Жаккара')
plt.title('Графики $J_{Inn}(a)$ и $J_{Out}(a)$')
plt.legend()
plt.grid(True)
plt.show()