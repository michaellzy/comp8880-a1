dataFolder = 'airports';
edgeFile = 'global-net.dat';
edgeFilePath = fullfile(dataFolder, edgeFile);

fid = fopen(edgeFilePath, 'r');
if fid < 0
    error('Failed to open global-net.dat.');
end
edges = fscanf(fid, '%d %d', [2, Inf])';
fclose(fid);

sortedEdges = sort(edges, 2);
uniqueEdges = unique(sortedEdges, 'rows');

% graph construction for undirected edges
G = graph(uniqueEdges(:,1), uniqueEdges(:,2));

% identify connected components
[bins, sizes] = conncomp(G);
numComponents = length(unique(bins));  
[~, idx] = max(sizes);                

% find the largest connected component
nodesInLargest = bins == idx;
G_largest = subgraph(G, nodesInLargest);

numNodesLargest = sizes(idx);
numEdgesLargest = numedges(G_largest);

fprintf('Number of connected components: %d\n', numComponents);
fprintf('Largest component contains:\n');
fprintf('  - Nodes: %d\n', numNodesLargest);
fprintf('  - Edges: %d\n', numEdgesLargest);

