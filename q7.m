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

betwCentrality = centrality(G, 'betweenness'); % Compute betweenness scores

% sort nodes by betweenness
[sortedBetw, sortedIdx] = sort(betwCentrality, 'descend');

% map id to city names
allNodeIDs = str2double(G.Nodes.Name);
nTop = min(10, numnodes(G));

fprintf('Top %d most central cities by betweenness centrality:\n', nTop);
fprintf('Rank | City/Airport Name               | Betweenness Centrality\n');
for i = 1:nTop
    nodeID = allNodeIDs(sortedIdx(i));  % Get numeric node ID
    cityName = idToCity(nodeID);        % Convert to city name
    fprintf('%2d   | %-30s | %.2f\n', i, cityName, sortedBetw(i));
end
