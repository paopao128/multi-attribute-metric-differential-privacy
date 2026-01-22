function masteragent = creatMasterGeoI(masteragent, distance_matrix, NR_OBFLOC, EPSILON)
    idx = 0;
    NR_NODE_IN_AGENT = size(masteragent.node, 2); 
    [row,col] = find(masteragent.adjacence_matrix_boundary > 0);
    masteragent.GeoI = sparse(size(row, 1)*NR_OBFLOC, NR_NODE_IN_AGENT*NR_OBFLOC); 
    for i = 1:1:size(row, 1)
        
        node_i = find(masteragent.node == row(i,1)); 
        node_j = find(masteragent.node == col(i,1)); 
        for k = 1:1:NR_OBFLOC
            masteragent.GeoI(idx+1, (node_i-1)*NR_OBFLOC + k) = 1;
            max_di=EPSILON;
            masteragent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k) = -exp(max_di*distance_matrix(row(i,1), col(i,1)));
            masteragent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k)=min(masteragent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k),-1);
            
            idx = idx + 1;
        end
    end
end