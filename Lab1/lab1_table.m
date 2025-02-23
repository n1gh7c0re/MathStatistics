% Параметры
norm_params = [0, 1];  % Параметры нормального распределения
cauchy_params = [0, 1]; % Параметры распределения Коши
poisson_params = 10;   % Параметр распределения Пуассона
uniform_params = [-sqrt(3), sqrt(3)]; % Параметры равномерного распределения

% Размеры выборок
sample_sizes = [10, 100, 1000];

% Количество повторений
num_repetitions = 1000;

% Массив для хранения результатов
results = struct('distribution', {}, 'sample_size', {}, 'mean', {}, 'median', {}, ...
                 'z1_4', {}, 'z3_4', {}, 'zQ', {}, 'variance_mean', {}, ...
                 'variance_median', {}, 'variance_zQ', {}, ...
                 'expected_mean', {}, 'expected_median', {}, 'expected_zQ', {});

% Цикл по распределениям
distributions = {'norm', 'cauchy', 'poisson', 'uniform'};
distribution_params = {norm_params, cauchy_params, poisson_params, uniform_params};

for i = 1:length(distributions)
    distrib_name = distributions{i};
    params = distribution_params{i};

    % Цикл по размерам выборок
    for j = 1:length(sample_sizes)
        n = sample_sizes(j);
        
        % Массивы для хранения результатов повторений
        means = zeros(1, num_repetitions);
        medians = zeros(1, num_repetitions);
        q1s = zeros(1, num_repetitions);
        q3s = zeros(1, num_repetitions);
        qs = zeros(1, num_repetitions);
        
        % Цикл по повторениям
        for k = 1:num_repetitions
            % Генерация выборки
            switch distrib_name
                case 'norm'
                    sample = normrnd(params(1), params(2), 1, n);
                case 'cauchy'
                    sample = cauchyrnd(params(1), params(2), 1, n);
                case 'poisson'
                    sample = poissrnd(params, 1, n);
                case 'uniform'
                    sample = unifrnd(params(1), params(2), 1, n);
            end

            % Вычисление статистических характеристик
            means(k) = mean(sample);
            medians(k) = median(sample);
            q1s(k) = quantile(sample, 0.25); % Первый квартиль
            q3s(k) = quantile(sample, 0.75); % Третий квартиль
            qs(k) = (q1s(k) + q3s(k)) / 2;     % Полусумма
        end

        % Сохранение средних значений и дисперсий
        results(end+1) = struct('distribution', distrib_name, ...
                                 'sample_size', n, ...
                                 'mean', mean(means), ...
                                 'median', mean(medians), ...
                                 'z1_4', mean(q1s), ...
                                 'z3_4', mean(q3s), ...
                                 'zQ', mean(qs), ...
                                 'variance_mean', var(means), ...    % Дисперсия для среднего
                                 'variance_median', var(medians), ... % Дисперсия для медианы
                                 'variance_zQ', var(qs), ...          % Дисперсия для zQ
                                 'expected_mean', mean(means), ...    % Ожидаемое значение для среднего
                                 'expected_median', mean(medians), ...% Ожидаемое значение для медианы
                                 'expected_zQ', mean(qs));             % Ожидаемое значение для zQ
    end
end

% Приведение результатов к таблице
T = struct2table(results);

% Сохранение таблицы в Excel файл
filename = 'results.xlsx'; % Имя файла
writetable(T, filename); % Сохранение таблицы

% Вывод результатов в нужном формате
disp(T);

function r = cauchyrnd(x0, gamma, m, n)
    u = rand(m, n); % Равномерное распределение [0, 1]
    r = x0 + gamma * tan(pi * (u - 0.5)); % Преобразование
end