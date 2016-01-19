function [  ] = compile_train_features_user_training( manualpath , feapath_base, maxn, minn, class2skip)
% function [  ] = compile_train_features_user_training( manualpath , feapath_base, maxn, minn, class2skip)
% For example:
%compile_train_features_user_training('C:\work\IFCB\user_training_test_data\manual\', 'C:\work\IFCB\user_training_test_data\features\', 100, 30, {'other'})
%IFCB classifier production: get training features from pre-computed bin feature files
%Heidi M. Sosik, Woods Hole Oceanographic Institution, converted to function Jan 2016
%

%manualpath = 'C:\work\IFCB\user_training_test_data\manual\'; % manual annotation files
%feapath_base = 'C:\work\IFCB\user_training_test_data\features\';
%maxn = 100; %maximum number of images per class to include
%minn = 30; %minimum number for inclusion
%class2skip = {'other'};
%class2skip = {};

manual_files = dir([manualpath 'D*.mat']);
manual_files = {manual_files.name}';
fea_files = regexprep(manual_files, '.mat', '_fea_v2.csv');
manual_files = regexprep(manual_files, '.mat', '');
%this presumes all the files have the same class to use
class2use = load([manualpath manual_files{1}], 'class2use_manual');
class2use = class2use.class2use_manual
%alternatively load your file
%class2use = load('class2use_TAMUG1', 'class2use');
%class2use = class2use.class2use;

outpath = [manualpath filesep 'summary' filesep];
if ~exist(outpath, 'dir')
    mkdir(outpath)
end;

fea_all = [];
class_all = [];
files_all = [];
for filecount = 1:length(manual_files), %looping over the manual files
    feapath=[feapath_base manual_files{filecount}(2:5) filesep];
    disp(['file ' num2str(filecount) ' of ' num2str(length(manual_files)) ': ' manual_files{filecount}])
    manual_temp = load([manualpath manual_files{filecount}]);
    
    fea_temp = importdata([feapath fea_files{filecount}]); %import data from the feature files
    
    if ~isequal(manual_temp.class2use_manual, class2use)
        disp('class2use_manual does not match previous files!!!')
        if isequal(manual_temp.class2use_manual, class2use(1:length(manual_temp.class2use_manual))),
            disp('class2use_manual missing entries on end')
        else
            keyboard
        end;
    end;
    %ind_nan=isnan(manual_temp.classlist(fea_temp.data(:,1),2));
    class_temp = manual_temp.classlist(fea_temp.data(:,1),2);
    ind_nan = find(isnan(class_temp));
    class_temp(ind_nan) = manual_temp.classlist(fea_temp.data(ind_nan,1),3);
    ind_nan = find(isnan(class_temp));
    class_temp(ind_nan) = [];
    fea_temp.data(ind_nan,:) = [];
    class_all = [class_all; class_temp];%This assume you have only manual annotations not classifier pre classified classes
    fea_all = [fea_all; fea_temp.data];
    files_all = [files_all; repmat(manual_files(filecount),size(fea_temp.data,1),1)];

end;

featitles = fea_temp.textdata;
[~,i] = setdiff(featitles, {'FilledArea' 'summedFilledArea' 'Area' 'ConvexArea' 'MajorAxisLength' 'MinorAxisLength' 'Perimeter', 'roi_number'}');
featitles = featitles(i);
roinum = fea_all(:,1);
fea_all = fea_all(:,i);

clear *temp

for classcount = 1:length(class2use),
    ii = find(class_all == classcount);
    n(classcount) = size(ii,1);
    n2del = n(classcount)-maxn;
    if n2del > 0,
        shuffle_ind = randperm(n(classcount));
        shuffle_ind = shuffle_ind(1:n2del);
        class_all(ii(shuffle_ind)) = [];
        fea_all(ii(shuffle_ind),:) = [];
        files_all(ii(shuffle_ind)) = [];
        roinum(ii(shuffle_ind)) = [];
        ii = find(class_all == classcount);
        n(classcount) = maxn;
    end;
    if n(classcount) < minn,
        class_all(ii) = [];
        fea_all(ii,:) = [];
        files_all(ii) = [];
        roinum(ii) = [];
        n(classcount) = 0;
    end;
end;

for classcount = 1:length(class2skip),
    ind = strmatch(class2skip(classcount),class2use);
    ii = find(class_all == ind);
    class_all(ii) = [];
    fea_all(ii,:) = [];
    files_all(ii) = [];
    roinum(ii) = [];
    n(classcount) = 0;
end;

train = fea_all;
class_vector = class_all;
targets = cellstr([char(files_all) repmat('_', length(class_vector),1) num2str(roinum, '%05.0f')]);
nclass = n;

datestring = datestr(now, 'ddmmmyyyy');

save([outpath 'UserExample_Train_' datestring], 'train', 'class_vector', 'targets', 'class2use', 'nclass', 'featitles');

