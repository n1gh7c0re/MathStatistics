clear all;
close all;
clc;

% Параметры
sample_sizes = [20, 60, 100];
rhos = [0, 0.5, 0.9];
num_iterations = 1000;

% Создание директории для сохранения графиков
if ~exist('plots', 'dir')
    mkdir('plots')
end

% Создаем figure для всех графиков
figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
tiledlayout(3, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% 1. Нормальное распределение
for i = 1:length(sample_sizes)
    n = sample_sizes(i);
    for j = 1:length(rhos)
        rho = rhos(j);
        
        % Инициализация массивов для статистик
        pearson_vals = zeros(num_iterations, 1);
        spearman_vals = zeros(num_iterations, 1);
        quadrant_vals = zeros(num_iterations, 1);
        
        for k = 1:num_iterations
            % Генерация выборки из двумерного нормального распределения
            mu = [0 0];
            Sigma = [1 rho; rho 1];
            data = mvnrnd(mu, Sigma, n);
            
            % Вычисление коэффициентов корреляции
            pearson_vals(k) = corr(data(:,1), data(:,2), 'Type', 'Pearson');
            spearman_vals(k) = corr(data(:,1), data(:,2), 'Type', 'Spearman');
            
            % Квадратный коэффициент корреляции (медианный)
            median_x = median(data(:,1));
            median_y = median(data(:,2));
            n11 = sum(data(:,1) > median_x & data(:,2) > median_y);
            n12 = sum(data(:,1) > median_x & data(:,2) <= median_y);
            n21 = sum(data(:,1) <= median_x & data(:,2) > median_y);
            n22 = sum(data(:,1) <= median_x & data(:,2) <= median_y);
            quadrant_vals(k) = ((n11 + n22) - (n12 + n21)) / n;
            
            % Сохранение первой выборки для визуализации
            if k == 1
                nexttile;
                scatter(data(:,1), data(:,2));
                hold on;
                
                % Эллипс равновероятности
                [X, Y] = meshgrid(linspace(min(data(:,1))-1, max(data(:,1))+1, 100), ...
                                 linspace(min(data(:,2))-1, max(data(:,2))+1, 100));
                Z = mvnpdf([X(:) Y(:)], mu, Sigma);
                Z = reshape(Z, size(X));
                contour(X, Y, Z, 5);
                
                title(sprintf('n=%d, \\rho=%.1f', n, rho));
                xlabel('X');
                ylabel('Y');
                grid on;
            end
        end
        
        % Вычисление статистик
        pearson_mean = mean(pearson_vals);
        pearson_mean_sq = mean(pearson_vals.^2);
        pearson_var = var(pearson_vals);
        
        spearman_mean = mean(spearman_vals);
        spearman_mean_sq = mean(spearman_vals.^2);
        spearman_var = var(spearman_vals);
        
        quadrant_mean = mean(quadrant_vals);
        quadrant_mean_sq = mean(quadrant_vals.^2);
        quadrant_var = var(quadrant_vals);
        
        % Вывод результатов
        fprintf('Нормальное распределение, n=%d, rho=%.1f:\n', n, rho);
        fprintf('Пирсон: mean=%.4f, mean_sq=%.4f, var=%.4f\n', pearson_mean, pearson_mean_sq, pearson_var);
        fprintf('Спирмен: mean=%.4f, mean_sq=%.4f, var=%.4f\n', spearman_mean, spearman_mean_sq, spearman_var);
        fprintf('Квадратный: mean=%.4f, mean_sq=%.4f, var=%.4f\n\n', quadrant_mean, quadrant_mean_sq, quadrant_var);
    end
end
sgtitle('Нормальное распределение с разными параметрами');

% Создаем новую figure для смеси распределений
figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.3]);
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% 2. Смесь нормальных распределений
for i = 1:length(sample_sizes)
    n = sample_sizes(i);
    
    % Инициализация массивов для статистик
    pearson_vals = zeros(num_iterations, 1);
    spearman_vals = zeros(num_iterations, 1);
    quadrant_vals = zeros(num_iterations, 1);
    
    for k = 1:num_iterations
        % Генерация выборки из смеси распределений
        data = zeros(n, 2);
        for m = 1:n
            if rand() < 0.9
                % Первое распределение (rho=0.9)
                mu = [0 0];
                Sigma = [1 0.9; 0.9 1];
                data(m,:) = mvnrnd(mu, Sigma, 1);
            else
                % Второе распределение (rho=-0.9)
                mu = [0 0];
                Sigma = [1 -0.9; -0.9 1];
                data(m,:) = mvnrnd(mu, Sigma, 1);
            end
        end
        
        % Вычисление коэффициентов корреляции
        pearson_vals(k) = corr(data(:,1), data(:,2), 'Type', 'Pearson');
        spearman_vals(k) = corr(data(:,1), data(:,2), 'Type', 'Spearman');
        
        % Квадратный коэффициент корреляции
        median_x = median(data(:,1));
        median_y = median(data(:,2));
        n11 = sum(data(:,1) > median_x & data(:,2) > median_y);
        n12 = sum(data(:,1) > median_x & data(:,2) <= median_y);
        n21 = sum(data(:,1) <= median_x & data(:,2) > median_y);
        n22 = sum(data(:,1) <= median_x & data(:,2) <= median_y);
        quadrant_vals(k) = ((n11 + n22) - (n12 + n21)) / n;
        
        % Сохранение первой выборки для визуализации
        if k == 1
            nexttile;
            scatter(data(:,1), data(:,2));
            title(sprintf('Смесь, n=%d', n));
            xlabel('X');
            ylabel('Y');
            grid on;
        end
    end
    
    % Вычисление статистик
    pearson_mean = mean(pearson_vals);
    pearson_mean_sq = mean(pearson_vals.^2);
    pearson_var = var(pearson_vals);
    
    spearman_mean = mean(spearman_vals);
    spearman_mean_sq = mean(spearman_vals.^2);
    spearman_var = var(spearman_vals);
    
    quadrant_mean = mean(quadrant_vals);
    quadrant_mean_sq = mean(quadrant_vals.^2);
    quadrant_var = var(quadrant_vals);
    
    % Вывод результатов
    fprintf('Смесь распределений, n=%d:\n', n);
    fprintf('Пирсон: mean=%.4f, mean_sq=%.4f, var=%.4f\n', pearson_mean, pearson_mean_sq, pearson_var);
    fprintf('Спирмен: mean=%.4f, mean_sq=%.4f, var=%.4f\n', spearman_mean, spearman_mean_sq, spearman_var);
    fprintf('Квадратный: mean=%.4f, mean_sq=%.4f, var=%.4f\n\n', quadrant_mean, quadrant_mean_sq, quadrant_var);
end
sgtitle('Смесь нормальных распределений (90% ρ=0.9 и 10% ρ=-0.9)');

% Сохраняем все графики
saveas(gcf, 'plots/all_mixture_plots.png');