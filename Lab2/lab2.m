% Задание: построение выборок, бокс-плоты и анализ выбросов
% Параметры для распределений
samples_sizes = [20, 100, 1000]; % Размеры выборок
lambda_poisson = 10;            % Параметр λ для распределения Пуассона
a_uniform = -sqrt(3);           % Параметр a для равномерного распределения
b_uniform = sqrt(3);            % Параметр b для равномерного распределения

% Метки распределений
distribution_labels = {'Normal', 'Cauchy', 'Poisson', 'Uniform'};
total_outliers = []; % Матрица для числа выбросов

% Построение бокс-плотов для каждой выборки и распределения
plot_index = 0;
for i = 1:length(samples_sizes) % По размерам выборок
    n = samples_sizes(i);

    % Генерация выборок
    normal_sample = normrnd(0, 1, [n, 1]); % Нормальное распределение
    cauchy_sample = trnd(1, [n, 1]);       % Распределение Коши
    poisson_sample = poissrnd(lambda_poisson, [n, 1]); % Пуассон
    uniform_sample = unifrnd(a_uniform, b_uniform, [n, 1]); % Равномерное
    
    % Формирование выборок для распределений
    data_samples = {normal_sample, cauchy_sample, poisson_sample, uniform_sample};

    % Построение графиков для каждого распределения
    for j = 1:4
        plot_index = plot_index + 1;

        % Создание новой фигуры для каждого графика
        figure('Name', sprintf('%s (n = %d)', distribution_labels{j}, n), ...
            'NumberTitle', 'off');

        % Построение бокс-плота с обозначением выбросов кружками
        boxplot(data_samples{j}, 'Symbol', 'o');
        title(sprintf('%s Distribution (n = %d)', distribution_labels{j}, n));
        ylabel('Value');

        % Установка индивидуального масштаба для графика
        ylim([min(data_samples{j}) - 1, max(data_samples{j}) + 1]);

        % Подсчёт числа выбросов
        Q1 = quantile(data_samples{j}, 0.25); % Первый квартиль
        Q3 = quantile(data_samples{j}, 0.75); % Третий квартиль
        IQR = Q3 - Q1; % Межквартильный размах
        lower_bound = Q1 - 1.5 * IQR; % Нижняя граница для выбросов
        upper_bound = Q3 + 1.5 * IQR; % Верхняя граница для выбросов
        outliers_count = sum(data_samples{j} < lower_bound | data_samples{j} > upper_bound);
        
        % Сохранение числа выбросов
        total_outliers(i, j) = outliers_count;
    end
end

% Формирование таблицы с выбросами
outliers_table = array2table(total_outliers, ...
    'VariableNames', distribution_labels, ...
    'RowNames', {'SampleSize20', 'SampleSize100', 'SampleSize1000'});
disp('Число выбросов для каждого распределения:');
disp(outliers_table);