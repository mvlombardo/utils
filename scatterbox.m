function scatterbox(data2plot,Grp,boxColors,dotColors,MAKELINE,lineColors,yLabel,xLabels)
%   scatterbox.m
%
%   DESCRIPTION
%       Create figure with boxplot and individual data points overlaid on
%       top. Can also add lines connecting paired data points.
%
%   INPUT
%       data2plot   = vector of data to plot
%       Grp         = grouping vector (usually composed of 1's and 2's)
%       boxColors	= matrix denoting rgb values. Should be [ngrp x 3]
%                     If only one color for all boxes, then its a 1x3 matrix         
%       dotColors   = matrix denoting rgb values. Should be [ngrp x 3]
%                     If only one color for all dots, then its a 1x3 matrix 
%       MAKELINE    = set to 1 if you want to add lines across the boxplots
%                     for showing paired data points across the boxplots.
%       lineColors  = 1 x 4 matrix of rgb and transparency values denoting 
%                     color for lines, if MAKELINE is set to 1
%       yLabel      = string to put as y-axis label
%       xLabels     = cell array of strings to put as x-axis tick labels
%
%   Example usage
%
%   data2plot = [normrnd(0.5,1,500,1);normrnd(1,1,500,1)];
%   Grp = [ones(500,1);ones(500,1)+1];
%   boxColors = [1 0 0; 0 0 1];
%   dotColors = boxColors;
%   MAKELINE = 1;
%   lineColors = [0 0 0 0.2]; % [r g b alpha]
%   yLabel = 'DV';
%   xLabels = {'Grp1', 'Grp2'};
%   scatterbox(data2plot,Grp,boxColors,dotColors,MAKELINE,lineColors,yLabel,xLabels)
%
%   written by mvlombardo - 05.09.2015
%

%% default settings
fontSize = 12;          % set font size to 12
fontWeight = 'b';       % set fonts to bold
backgroundColor = 'w';  % background color for figure
lineMarkerSymbol = ':'; % marker symbol default
alphaLevel = 0.5;       % setting for line transparency
jitter_sd = 0.02;       % setting for controlling how much jitter to add


%% make a figure
figure; 
set(gcf,'color',backgroundColor); % sets background color

% create boxplot
boxplot(data2plot,Grp);
hold on; 

% overlay scatterplot of individual dots for each data point
uniqueGrps = unique(Grp);  % find number of unique groups

% introduce jitter on x-axis
Grp_jitter = Grp + normrnd(0,jitter_sd,size(Grp,1),1); 

if size(dotColors,1)==1 % if you only want one color for all dots
    s = scatter(Grp_jitter,data2plot); % make scatterplot
    % change color on dots
    set(s,'MarkerFaceColor',dotColors,'MarkerEdgeColor',dotColors);
else % if you want different colors for different groups
    for i = 1:length(uniqueGrps)
        % make scatterplot
        s = scatter(Grp_jitter(Grp==uniqueGrps(i)),data2plot(Grp==uniqueGrps(i)));
        % change color on dots
        set(s,'MarkerFaceColor',dotColors(i,:),'MarkerEdgeColor',dotColors(i,:));
    end % for i
end % if

% insert y-axis label
ylabel(yLabel);

% change x-axis tick labels and font size and weight
set(gca,'XTickLabel',xLabels,'fontsize',fontSize,'fontweight',fontWeight);

% turn grid on and make axis square
grid on; 
axis square;

% edit boxplot elements
tagNames = {'Outliers','Median','Box','Lower Adjacent Value','Upper Adjacent Value','Lower Whisker','Upper Whisker'};
for itag = 1:length(tagNames)
    h = findobj(gca,'Tag',tagNames{itag});
    h_tmp = findobj(gca,'Tag',tagNames{length(tagNames)});
    
    if strcmp(tagNames{itag},'Outliers') % what to do for outliers
        for i = 1:length(xLabels)
            h(i).Marker = 'none'; % delete default outlier marker
        end % for i
    else % what to do on all other boxplot elements
        if size(boxColors,1)==1 % if you want everything one color
            set(h,'linewidth',2,'color',boxColors); % change color on boxplot element
        else % if you want different colors for different groups
            for i = 1:length(xLabels)
                boxidx = h_tmp(i).XData(1); % finds out which group
                % changes color for that group's boxplot element
                set(h(i),'linewidth',2,'color',boxColors(boxidx,:));
            end % for i
        end % if size(boxColors,1)==1
    end % if strcmp(tagNames{itag},'Outlier's)
end % for itag


%% make lines connecting paired data points
if MAKELINE
    % if line transparency wasn't specified, use the default value
    if size(lineColors,2)~=4
        lineColors = [lineColors alphaLevel];
    end % if size(lineColors,2)
    
    % set up data for adding lines
    Xgrp = [];  Ydata = [];
    for i = 1:length(uniqueGrps)
        Xgrp = [Xgrp Grp_jitter(Grp==uniqueGrps(i))];
        Ydata = [Ydata data2plot(Grp==uniqueGrps(i))];
    end % for i
    
    % add lines to the figure
    for i = 1:size(Ydata,1)
        hold on;
        h = plot(Xgrp(i,:),Ydata(i,:),lineMarkerSymbol);
        % set line colors and transparency
        set(h,'color',lineColors);
    end % for i
end % if MAKELINE

