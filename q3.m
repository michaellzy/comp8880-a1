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

allNodeIDs = str2double(G.Nodes.Name);

% Sort degree in descending order
[sortedDeg, sortedIdx] = sort(degrees, 'descend');

% find top 10 cities with highest degree
nTop = min(10, numnodes(G));
fprintf('Top %d highest-degree nodes in the component:\n', nTop);

for i = 1:nTop
    nodePos  = sortedIdx(i);            
    nodeID   = allNodeIDs(nodePos);    
    cityName = idToCity(nodeID);
    fprintf('%2d) %s, connected to %d other nodes.\n', i, cityName, sortedDeg(i));
end
