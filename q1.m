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

G = graph(uniqueEdges(:,1), uniqueEdges(:,2));

% calculate node numbers and edge numbers
numNodes = numnodes(G);
numEdges = numedges(G);

fprintf('Number of nodes: %d\n', numNodes);
fprintf('Number of undirected edges: %d\n', numEdges);