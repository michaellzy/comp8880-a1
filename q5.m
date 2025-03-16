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

% Compute the diameter (longest shortest path)
D = distances(G); % Compute pairwise shortest path distances
D(D == Inf) = 0;  % Remove Inf values
[diameter, linearIdx] = max(D(:)); % Find the maximum distance (diameter)

% Convert linear index to (row, column) indices
[row, col] = ind2sub(size(D), linearIdx);
node1_ID = str2double(G.Nodes.Name(row));  % Get numeric node ID for first city
node2_ID = str2double(G.Nodes.Name(col));  % Get numeric node ID for second city

% Get city names for the two endpoints of the longest shortest path
city1 = idToCity(node1_ID);
city2 = idToCity(node2_ID);

% Compute the actual shortest path between these two cities
pathNodes = shortestpath(G, row, col);

% Convert path nodes to city names
pathCityNames = cellfun(@(x) idToCity(str2double(x)), G.Nodes.Name(pathNodes), 'UniformOutput', false);

fprintf('Graph Diameter: %d\n', diameter);
fprintf('Longest shortest path is between %s and %s.\n', city1, city2);
fprintf('Path:\n');
disp(pathCityNames');
