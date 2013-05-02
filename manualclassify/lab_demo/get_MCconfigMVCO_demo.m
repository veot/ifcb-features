function [ MCconfig ] = get_MCconfigMVCO(  )
%function [ MCconfig ] = get_MCconfigMVCO(  )
%   Detailed explanation goes here
%MCconfig.filenum2start = 182;  %In the middle of batch classifying lepto
%1-25-13

MCconfig.filenum2start = 1;  %USER select file number to begin (within the chosen set)

%MCconfig.pick_mode = 'correct_or_subdivide'; %USER choose one from case list
MCconfig.pick_mode = 'raw_roi';

MCconfig.resultpath = '\\queenrose\g_work_ifcb1\Demo_27Apr2013\ManualClassify\'; %USER set
%MCconfig.resultpath = '\\raspberry\d_work\IFCB1\ifcb_data_mvco_jun06\Manual_fromClass\'; %USER set
MCconfig.class_filestr = '_class_v1'; %USER set, string appended on roi name for class files

temp = load('class2use_MVCOmanual3', 'class2use'); 
%MCconfig.class2use = [temp.class2use 'unclassified'];
MCconfig.class2use = temp.class2use;
MCconfig.default_class = 'other';
temp = load('class2use_MVCOciliate', 'class2use_sub4'); 
MCconfig.class2use_sub = temp.class2use_sub4;
MCconfig.sub_default_class = 'Ciliate_mix';
MCconfig.classstr = 'ciliate';
big_only = 0; %case for picking Laboea and tintinnids only

MCconfig.class2view1 = MCconfig.class2use; %case to view all
%MCconfig.class2view1 = { }; %example to skip view1 
%MCconfig.class2view1 = setdiff(MCconfig.class2use, {'bad' 'mix'}); %example to skip a few
%MCconfig.class2view1 = intersect(MCconfig.class2use, {'Ditylum'}); %example to select a few
%MCconfig.class2view2 = MCconfig.class2use_sub; %case to view all ciliates
MCconfig.class2view2 = { }; %example to skip view2

if ~exist(MCconfig.resultpath, 'dir'),
    dos(['mkdir ' MCconfig.resultpath]);
end;

end
