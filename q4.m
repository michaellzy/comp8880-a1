dataFolder = 'airports';
edgeFile   = 'global-net.dat';
cityFile   = 'global-cities.dat';

% read city data and build {nodeID:cityName} map
cityFilePath = fullfile(dataFolder, cityFile);
fid = fopen(cityFilePath, 'r');
if fid < 0
    error('Failed to open global-cities.dat.');
end
dataCities = textscan(fid, '%s %d %s', 'Delimiter', '|');
fclose(fid);

nodeIDs   = dataCities{2};
cityNames = dataCities{3};
idToCity  = containers.Map(nodeIDs, cityNames);

% read edge data and build the full graph
edgeFilePath = fullfile(dataFolder, edgeFile);
fid = fopen(edgeFilePath, 'r');
if fid < 0
    error('Failed to open global-net.dat.');
end
edges = fscanf(fid, '%d %d', [2, Inf])';
fclose(fid);

sortedEdges = sort(edges, 2);
uniqueEdges = unique(sortedEdges, 'rows');

% Convert nodeIDs to strings for proper graph node referencing
nodeID_str = string(nodeIDs);
G = graph(uniqueEdges(:,1), uniqueEdges(:,2), [], nodeID_str);

% extract the largest connected component from G
[compLabels, compSizes] = conncomp(G);
[~, largestIndex] = max(compSizes);
largestCompNodes = (compLabels == largestIndex);
G = subgraph(G, largestCompNodes);

% compute degrees in largest component G
degrees = degree(G);

% calculate degree distribution
uniqueDegrees = unique(degrees);
counts = histc(degrees, uniqueDegrees);
proportions = counts / numnodes(G);

% remove any  points with a 0 entry
validPoints = proportions > 0;
x = uniqueDegrees(validPoints);
y = proportions(validPoints);

% plot linear graph
figure('Name', 'Degree Distribution');
scatter(x, y, 40, 'filled', 'MarkerFaceColor', [0 0.447 0.741]);
xlabel('Degree (x)');
ylabel('Fraction of Nodes (y)');
title('Degree Distribution (Linear Scale)');
xlim([min(x)-0.5, max(x)+0.5]);
grid on;

% plot graph with log-log degree distribution
figure('Name', 'Log-Log Degree Distribution');
loglog(x, y, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.85 0.325 0.098]);
xlabel('Degree (x)');
ylabel('Fraction of Nodes (y)');
title('Degree Distribution (Log-Log Scale)');
xlim([0.8*min(x), 1.2*max(x)]);
set(gca, 'XScale', 'log', 'YScale', 'log', ...
         'XTick', 10.^(0:ceil(log10(max(x)))), ...
         'YTick', 10.^(-5:0));
grid on;