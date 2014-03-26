
I've been poking around  igraph and spatgraphs but have not been able to 
find a sufficiently simple example to make sense of. 

Suppose I have three points A, B, and C. 

The path from A to B is 3 units, from B to C is 4 units, and from A to C is 
8 units. 

Could someone provide a simple coding example showing that A-B-C represents 
the shortest path? 


library(igraph)
#1 make a graph, giving a two-column matrix of FROM and TO node names: 

ABC <- graph.edgelist(cbind(c("A","B","C"),c("B","C","A"))) 
plot(ABC)

#2 attach distances as weights: 
E(ABC)$weight <- c(3,4,8) 

#3 see what we got: 
ABC 

Vertices: 3 
Edges: 3 
Directed: TRUE 
Edges: 

[0] 'A' -> 'B' 
[1] 'B' -> 'C' 
[2] 'A' -> 'C' 

# Note this is a Directed graph. There's no way back from B to A! 

#4 shortest path from A to C: 

plot(get.shortest.paths(ABC, from="A", to="C"))

plot(ABC)

[[1]] 
[1] 0 1 2 

#And since there might be more than one shortest path, the return is a 
#list. Here it has one element, and the numbers are the indices of the 
#nodes.  Starting from zero[1]. This is computer science, after all. To 
#get the nodes, index the V (vertices) function: 

V(ABC)[get.shortest.paths(ABC,from="A",to="C")[[1]]] 
Vertex sequence: 
[1] "A" "B" "C" 

#5 just to check, lets set the distances to all 1 and see if the algorithm figures out the direct route is quicker: 

E(ABC)$weight = c(1,1,1) 
V(ABC)[get.shortest.paths(ABC,from="A",to="C")[[1]]] 

Vertex sequence: 
[1] "A" "C" 
