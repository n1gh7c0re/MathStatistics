% Задание параметров распределений
norm_params = [0, 1];  % Параметры нормального распределения (среднее, стандартное отклонение)
cauchy_params = [0, 1]; % Параметры распределения Коши (местоположение, масштаб)
poisson_params = 10;   % Параметр распределения Пуассона (лямбда)
uniform_params = [-sqrt(3), sqrt(3)]; % Параметры равномерного распределения (минимальное, максимальное)

% Размеры выборок
sample_sizes = [10, 50, 1000];

% Цикл по распределениям
distributions = {'norm', 'cauchy', 'poisson', 'uniform'};
distribution_params = {norm_params, cauchy_params, poisson_params, uniform_params};



for i = 1:length(distributions)
    distrib_name = distributions{i};
    params = distribution_params{i};

    % Цикл по размерам выборок
    for j = 1:length(sample_sizes)
        n = sample_sizes(j);
        
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
        
        % Построение гистограммы и графика плотности
        figure;
        histogram(sample, 'Normalization', 'pdf');
        hold on;
        
        switch distrib_name
            case 'norm'
                x = linspace(min(sample)-1, max(sample)+1, 1000);
                y = normpdf(x, params(1), params(2));
                plot(x, y, 'LineWidth', 2);
            case 'cauchy'
                x = linspace(min(sample)-1, max(sample)+1, 1000);
                y = cauchy_pdf(x, params(1), params(2));
                plot(x, y, 'LineWidth', 2);
            case 'poisson'
                x = 0:max(sample);
                y = poisspdf(x, params);
                plot(x, y, 'LineWidth', 2);
            case 'uniform'
                x = linspace(params(1), params(2), 1000);
                y = unifpdf(x, params(1), params(2));
                plot(x, y, 'LineWidth', 2);
        end
        
        hold off;
        title([distrib_name ', n = ' num2str(n)]);
        xlabel('x');
        ylabel('Плотность');
        legend('Гистограмма', 'Плотность');
    end
end


function r = cauchyrnd(x0, gamma, m, n)
    u = rand(m, n); % Равномерное распределение [0, 1]
    r = x0 + gamma * tan(pi * (u - 0.5)); % Преобразование
end

% Вспомогательная функция для плотности Коши
function y = cauchy_pdf(x, x0, gamma)
  y = (gamma / pi) ./ (gamma^2 + (x - x0).^2);
end
