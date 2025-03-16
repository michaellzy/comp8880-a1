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

% compute shortest path from CBR to CPT
if isKey(airportToID, 'CBR') && isKey(airportToID, 'CPT')
    sourceID = airportToID('CBR');
    targetID = airportToID('CPT');
else
    error('One or both airport codes not found in dataset.');
end

% Find corresponding indices in G (since G is a subgraph)
sourceIdx = find(str2double(G.Nodes.Name) == sourceID);
targetIdx = find(str2double(G.Nodes.Name) == targetID);

% Compute shortest path
shortestPathNodes = shortestpath(G, sourceIdx, targetIdx);

% Convert node IDs back to city names
shortestPathCityNames = cellfun(@(x) idToCity(str2double(x)), G.Nodes.Name(shortestPathNodes), 'UniformOutput', false);

% Print results
fprintf('The shortest path from Canberra (CBR) to Cape Town (CPT) requires %d flights.\n', numel(shortestPathCityNames)-1);
fprintf('Route:\n');
disp(shortestPathCityNames');
