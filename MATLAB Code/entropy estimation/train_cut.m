%% test
mdl_rf = TreeBagger(100, X_train, y_train, 'Method', 'classification');
                    
% Model 3: SVM

mdl_svm = fitcsvm(X_train, y_train, 'KernelFunction', 'rbf');

% Make Predictions and Evaluate

% Logistic Regression predictions
%y_pred_logistic = double(predict(mdl_logistic, X_test) > 0.5);

% Random Forest predictions
y_pred_rf_scores = predict(mdl_rf, X_test);
% Convert cell array to numeric and then to 0/1
if iscell(y_pred_rf_scores)
    y_pred_rf = double(strcmp(y_pred_rf_scores, '1'));
else
    y_pred_rf = double(y_pred_rf_scores) - 1;
end

% SVM predictions
y_pred_svm = double(predict(mdl_svm, X_test));

% Step 6: Calculate Performance Metrics


% models = {'Logistic Regression', 'Random Forest', 'SVM'};
% predictions = {y_pred_logistic, y_pred_rf, y_pred_svm};
models = {'Random Forest', 'SVM'};
predictions = {y_pred_rf, y_pred_svm};
accuracy=zeros(1,2);
precision=zeros(1,2);
recall=zeros(1,2);
f1_score=zeros(1,2);
for i = 1:length(models)
    y_pred = predictions{i};
    
    % Calculate metrics
    accuracy(1,i) = sum(y_pred == y_test) / length(y_test);
    
    % Confusion matrix
    TP = sum((y_pred == 1) & (y_test == 1));
    TN = sum((y_pred == 0) & (y_test == 0));
    FP = sum((y_pred == 1) & (y_test == 0));
    FN = sum((y_pred == 0) & (y_test == 1));
    
    % Precision, Recall, F1-score
    precision(1,i) = TP / (TP + FP);
    recall(1,i) = TP / (TP + FN);
    f1_score(1,i) = 2 * (precision(1,i) * recall(1,i)) / (precision(1,i) + recall(1,i));
    
    % Display results
    % fprintf('\n%s:\n', models{i});
    % fprintf('  Accuracy:  %.4f\n', accuracy(1,i));
    % fprintf('  Precision: %.4f\n', precision(1,i));
    % fprintf('  Recall:    %.4f\n', recall(1,i));
    % fprintf('  F1-Score:  %.4f\n', f1_score(1,i));
end
accuracy_mean=mean(accuracy);
ac_change=(accuracy_mean_ori-accuracy_mean)/accuracy_mean_ori*10000;