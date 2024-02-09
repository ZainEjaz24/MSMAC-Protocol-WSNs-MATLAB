% MS-MAC FOR WIRELESS SENSOR NETWORKS IMPLEMENTATION AND SIMULATION WITH VIRTUAL CLUSTERS
% IMPLEMENTED BY ZAIN EJAZ (Github ZainEjaz24) 

% Constants
synchronizationPeriod = 10;  % Synchronization period in seconds
activeZoneThreshold = 1/4;  % Example threshold for active zone, adjust as needed
virtualClusterDuration = 120;  % Duration of virtual clusters in seconds
connectionSetupTime = 10;  % Connection setup time in seconds

% Simulation parameters
simulationTime = 600;  % Total simulation time in seconds
numNodes = 10;  % Number of nodes in the network
numClusters = 3;  % Number of virtual clusters

% Initialize nodes
nodes = struct('id', num2cell(1:numNodes), ...  % Assign unique IDs to each node in the network
               'isMobile', num2cell(rand(1, numNodes) > 0.5), ...  % Generate random values (0 or 1) to indicate if a node is mobile
               'speed', num2cell(rand(1, numNodes)), ...  % Generate random speeds for each node (for mobile nodes)
               'position', num2cell(rand(1, numNodes)), ...  % Generate random positions for each node
               'mobilityInfo', cell(1, numNodes), ...  % Initialize empty cell array to store mobility information for each node
               'cluster', num2cell(randi(numClusters, 1, numNodes)));  % Assign nodes to random initial virtual clusters

% Plotting setup
figure;  % Create a new figure for plotting
hold on;  % Enable hold on to allow multiple plots on the same figure
title('MS-MAC Simulation with Virtual Clusters');  % Set the title of the plot
xlabel('X-axis');  % Label the x-axis
ylabel('Y-axis');  % Label the y-axis
axis equal;  % Ensure equal aspect ratio to prevent distortion in the plot
xlim([0 1]);  % Set the limits of the x-axis from 0 to 1
ylim([0 1]);  % Set the limits of the y-axis from 0 to 1

% Simulation loop
for currentTime = 0:synchronizationPeriod:simulationTime
    % Loop through the simulation time in steps of synchronization period
    
    % Update the array with the new X-positions
    xPositions = [nodes.position];
    
    % Plot nodes' trajectories with different colors based on mobility
    for i = 1:numNodes
        if nodes(i).isMobile
            % Update positions of moving nodes based on detectMobility
            nodes(i).position = nodes(i).position + nodes(i).speed;
            % Plotting with only node numbers and unique colors
            plot(nodes(i).position, 0, 'o-', 'MarkerSize', 8, 'DisplayName', ['Node ', num2str(i)], 'Color', rand(1, 3));
        else
            % For stationary nodes, update plot without moving them
            plot(nodes(i).position, 0, 'o-', 'MarkerSize', 8, 'DisplayName', ['Node ', num2str(i)], 'Color', rand(1, 3)));
        end
    end
    legend('show'); % Show legend
    drawnow;
    
    % Pause for synchronization period
    pause(synchronizationPeriod);
    
    % Broadcast SYNC message with mobility information
    for i = 1:numNodes
        nodes(i).mobilityInfo = detectMobility(nodes, i);
        broadcastSyncMessage(nodes(i).id, nodes(i).mobilityInfo, numNodes);
    end
    
    % Check each node's scenario
    for i = 1:numNodes
        if ~isempty(nodes(i).mobilityInfo)
            % Node is in an active zone
            synchronizationPeriod = adjustSynchronizationPeriod(nodes(i).id, nodes(i).mobilityInfo, synchronizationPeriod);
            handleActiveZone(nodes, i);
        else
            % Node is stationary
            handleStationaryNode(nodes, i, currentTime, virtualClusterDuration, numClusters, synchronizationPeriod);
        end
    end
end

% Updated detectMobility function
function mobilityInfo = detectMobility(nodes, currentNode)
    if nodes(currentNode).isMobile
        % Simple physics-based model for node movement
        acceleration = 0.1 * randn();  % Random acceleration
        nodes(currentNode).speed = nodes(currentNode).speed + acceleration;
        nodes(currentNode).position = nodes(currentNode).position + nodes(currentNode).speed;
        mobilityInfo = nodes(currentNode).speed;
    else
        % For stationary nodes, return empty mobilityInfo
        mobilityInfo = [];
    end
end

% Function to broadcast SYNC message
function broadcastSyncMessage(nodeId, mobilityInfo, numNodes)
    fprintf('Node %d broadcasting SYNC message with mobility info: %f\n', nodeId, mobilityInfo);
    
    % Simulate sending SYNC message to other nodes in the network
    % For demonstration purposes, let's assume all other nodes receive the message
    fprintf('Node %d received SYNC message\n', setdiff(1:numNodes, nodeId));
end

% Function to adjust synchronization period based on mobility
function newSynchronizationPeriod = adjustSynchronizationPeriod(nodeId, mobilityInfo, currentSynchronizationPeriod)
    % Adjust synchronization period based on mobile speed
    if mobilityInfo > 0.2  % Adjust the threshold as needed
        newSynchronizationPeriod = currentSynchronizationPeriod / 2;
    else
        newSynchronizationPeriod = currentSynchronizationPeriod;
    end
    
    fprintf('Node %d adjusting synchronization period to: %f seconds\n', nodeId, newSynchronizationPeriod);
end

% Function to handle actions in the active zone
function handleActiveZone(nodes, currentNode)
    % Actions specific to active zone
    % Example: Adjust transmission power or data rate
    activeZoneThreshold = 1/4;  % Example threshold, adjust as needed
    if ~isempty(nodes(currentNode).mobilityInfo) && nodes(currentNode).mobilityInfo > activeZoneThreshold
        % Additional actions for fast-moving nodes
        scatter(nodes(currentNode).position, 0, 100, rand(1, 3), 'filled', 'Marker', 'd');
    else
        % Standard active zone actions
        scatter(nodes(currentNode).position, 0, 50, rand(1, 3), 'filled', 'Marker', 's');
    end
end

% Function to handle actions for stationary nodes
function handleStationaryNode(nodes, currentNode, currentTime, virtualClusterDuration, numClusters, synchronizationPeriod)
    % Actions for stationary nodes
    % Example: Implement energy-saving mechanisms
    if mod(currentTime, virtualClusterDuration) == 0
        % Periodic synchronization actions for stationary nodes
        scatter(nodes(currentNode).position, 0, 70, rand(1, 3), 'filled', 'Marker', 'o');
        
        % Simulate data transmission within the virtual cluster
        % Extract the cluster ID of the current node
clusterId = nodes(currentNode).cluster;

% Find all nodes in the same virtual cluster as the current node
nodesInCluster = find([nodes.cluster] == clusterId);

% Print a message indicating data transmission within the virtual cluster
fprintf('Transmitting data within virtual cluster %d\n', clusterId);

% Iterate over nodes in the virtual cluster to simulate data transmission
for j = nodesInCluster
    fprintf('Node %d transmitting data\n', j);
end

    end
end
