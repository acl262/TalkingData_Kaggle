clear
ds = datastore('train_sample.csv');
ds.TextscanFormats = {'%f','%f','%f','%f','%f','%q','%q','%f'};
ds2 = datastore('test.csv');
train_inp = ds.readall;
train = table2array(train_inp(:,{'app','os','device','ip','channel'}));
train = [train convertTimeToNum(table2array(train_inp(:,{'click_time'})))];

train_truth = table2array(train_inp(:,{'is_attributed'}));
train_truth = uint8(train_truth);

number_of_train = int32(length(train_truth) * 0.9);

varify_truth = train_truth((number_of_train+1):end);

varify_dimention = train((number_of_train+1):end,:);

train = train(1:number_of_train,:);

train_truth = train_truth(1:number_of_train);

fprintf('Started training at time %s\n', datestr(now,'HH:MM:SS.FFF'))

fprintf('Sample size: %d\n', number_of_train)

SVMModel = fitcsvm(train,train_truth);

fprintf('Training ended at time %s\n', datestr(now,'HH:MM:SS.FFF'))

[label,score] = predict(SVMModel,varify_dimention);

CVSVMModel = crossval(SVMModel);

classLoss = kfoldLoss(CVSVMModel);

correct_rate = 1 - length(find(varify_truth~=label))/length(label);

ds_TEST = datastore('test.csv');

time_format = 'mmmm dd, yyyy HH:MM:SS.FFF AM';

fprintf('Started producing prediction at time %s\n', datestr(now,time_format))

while hasdata(ds_TEST)
    fprintf('%s\n', datestr(now,'HH:MM:SS.FFF'))
    test_inp = ds_TEST.read;
    test = table2array(test_inp(:,{'app','os','device','ip','channel'}));
    test = [test convertTimeToNum(table2array(train_inp(:,{'click_time'})))];
    
end

fprintf('All Done %s\n', datestr(now,time_format))



