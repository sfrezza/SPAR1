COPYRIGHT 1996 Stephen T. Frezza




Notes on the algorithm & terms used for place.c:  

(Or the current state of affairs, 30 Oct, '89)

The function place() (place.c) does the placement of all modules,
setting their position first on a virtual page, and then on a real
page.  It is intended to provide a logical structuring of the
resulting schematic, with sufficient space between the modules for
them to be routed.

Relevant command-line arguments are specified by their '-' values.



Placement Algorithm Outline:

	I Read File:
		a) Build Module List {M}.
		b) Build Systerm List {Systerms}.

	II Discover Partitions:
		a) Build Connection Matrix {C}.
		b) select the best two clusters to merge.
 		c) merge the given clusters (incrementally add to {P}).
		d) continue b & c until there is only one cluster remaining.

	III Place all Modules within the partitions: (box placement)
		a) Find the longest string in P[i] and place it.  Ignore any 
                   systerms within the string (this is the first box within 
                   the partition).
		b) Find the next longest string in P[i], place it (this is a 
                   second box). Again, ignore all systerms.
		c) Position the two boxes (strings) adjacent to each other 
                   (adjoin the two boxes).  The new box is placed to the top, 
                   left, right, etc.. of the already placed boxes based on how
                   the two sets of modules (the already-placed boxes, and
		   the box being placed) are interconnected.
		d) continue b & c until all modules within P[i] are placed.

	IV Place each partition:
		a) choose the partition which is most highly connected to the 
                   others: It's virtual coordinates (from III) become the page
                   coordinates.
		b) place the next most highly-connected partitions w.r.t. the 
                   placed partitions. This is accomplished using the same 
                   criteria as with the box placement.
		c) continue b until all partitions are placed.
		
	V Place the Systerm Partitions:
		a) Align each systerm on the nearest terminal to which it is 
                   connected that does not result in an illegal placement.  
                   If this fails, calculate the next free position in the 
                   column, and place the terminal there.




SPAR Terminology:

Module - an icon that is placed on the page.  In the default (post
    script) mode, all such icons are created on the fly, that is based on
    the number of inputs and outputs, and the type of gate used.  The size
    is calculated as the terminals are read in from the netlist (see
    parse.c).  The PostScript icons are created during the file generation (after
    routing) in file psfigs.c.  The predefined icon types are BUFFER, NOT,
    AND, NAND, OR, NOR, XOR, XNOR, OUTTERM, INTERM, and the omniscient
    (default) BOX. Modules are grouped into two sets: SysTerms (all system
    terminals, from the vhdl port specs) and others M, where the
    {systerms} are a subset of {M}. Modules have such aspects a size,
    position, names, types, and a list of terminals.

Terminal - One connection to a module.  These are broken down into
    three types: IN, INOUT, & OUT.  Terminals have names, and positions
    relative to the position of their parent module.  They also point to
    the net structure to which they also belong.

Net - a collection of terminals.  In the classic sense, this is a
    structure which unites a group of terminals which share a common
    value.  All connection information may be traced by following modules
    to terminals to nets to terminals to modules, etc..

String - a sequence of modules within a partition, where all of the
    modules are ordered by an output->input relationship.  The head of a
    string has some OUT or INOUT terminal that connects it to the second
    module in the string and so on.

Complex String - a sequence of modules within a partition that
    contains two modules that are cross-coupled at some level of removal.
    This cross-coupling implies that the two modules in question should be
    placed in the same column, even though they have an out->in
    relationship.  Each of these modules then becomes the head of further
    strings.  (This transforms strings from lists to binary trees arranged
    horizontally.)

Cross-Coupling - Implies that two modules both have out->in
    relationships to each other at some level of removal.  The classic
    level-1 cross coupling is the standard RS flip-flop, built from
    two-input NAND gates.  The level to which the system will look for
    these cross-coupled modules is (default 2) set by the -l# option.

Partition - is an arbitrary collection of modules, defined by one of
    several partitioning rules. These rules are designed to determine if
    clusters of modules maintain a 'good' partition or not.  The current
    partitioning (only mildly successful) rules are based on:

	- partition size - is the number of modules and external
	connections within the cluster less than some default (-s#, -c#)
	value?  (default rule : -p1)

	- Ratio (rent-like) - Is the ratio of the external connections
	to the cluster to the number of modules within the cluster less than
	some pre-determined (-r#) value? (-p2)

	- Slope - partition slope, that is does the number of
	connections emanating from this new cluster represent a decrease from
	the number of connections emanating from either of the two clusters
	that compose it? (-p3).

For whatever rule is in operation during the clustering process, a
cluster is clipped from the tree and saved as a partition whenever the
answer to the partitioning question above is yes.  A single module is
defined to be a good partition.

Cluster - Is another arbitrary collection of modules.  Each cluster is
    a node or leaf of a binary tree, and is formed during the clustering
    process by merging two smaller clusters. Initially, each module is
    assigned to its own cluster.  Each row and column of the connection
    matrix corresponds to one cluster. Clusters have a size (the number of
    modules contained), and a number of connections (external to the
    cluster).

Cluster Tree - The collection of all modules, as created by a sequence
    of mergers where two clusters are joined to form a third.  This is in
    the form of a binary tree, where all leaf nodes are clusters
    containing a single module.

Connection Matrix - Is a square matrix where every row and column
    contains the connection information for how each cluster currently
    relates to every other one.  The matrix entries form the basis for the
    'connection' math used by all of the partition rules, and the
    information contained is used to calculate which clusters will be
    merged next. There are three forms to this matrix (controlled by the
    -m# flag)

	- Symmetric (default -m0) each C[i,j] corresponds to a count of
	the inputs AND outputs between cluster(i) and cluster(j).  Each C[k,k]
	contains the sum of the row i, and hence the count of the number
	connections external to cluster(k).

	- In-Out (-m1) each C[i,j] corresponds to a count of the
	number of connections FROM cluster(i) to cluster(j).  It can be read
	as "cluster(i) FEEDS cluster(j)."  The C[k,k] element corresponds to
	the row sum.

	- Out-In (-m-1) like the In-Out case, only C[i,j] corresponds
	to a count of connections from j to i, that is "cluster(i) IS FED BY
	cluster(j)." C[k,k] corresponds to the column sum.  Note that the two
	signed matrices are the transpose of each other.


Clustering process - Is a sequence of cluster mergers, where two
    clusters are selected from the set of clusters remaining, and merged.
    The merger process continues until only one cluster remains, which
    becomes its own partition. Each merger results in either one of the
    two clusters being 'clipped' from the cluster tree that is forming, or
    in a new cluster that is the combination of the previous two.  In
    either event, one row and one column are removed from the connection
    matrix.  The output of this process is the collection of partitions {P}.

Merger - is an operation on the clusters and the connection matrix
    whereby two clusters are combined to form a third.  The resulting
    number of connections contained in the cluster is the sum of the
    connections external to each of the sibling clusters, minus the number
    of connections between the two clusters.  If the merger is successful,
    then the pertinent row and column of the connection matrix will
    reflect the connections from the remaining clusters to the new
    cluster.  If it fails, (i.e.: a partition was 'clipped') then the
    remaining cluster's information replaces the row and column that would
    have held the merged information.  Note that not only is the table
    information changed: the info stored within the clusters is also
    updated.

Cluster Selection - Is accomplished by stepping through the connection
    matrix, and selecting the two clusters {Ci, Cj} who's resulting number
    of connections (normalized to the overall number of connections
    between them) is largest:

				C[i,i] + C[j,j] - C[i,j] - C[j,i]
	i, j where:	Max(	---------------------------------  )
					C[i,i] + C[j,j]

        over all i, j < cluster_count

	
        Box Placement - Given a set of placed modules & their bounding
    box, and a set of unplaced modules (another box), determine to which
    side of the current bounding box the new box should be added.  This is
    entirely dependent upon the signal flow between the two boxes. The
    signal flow between the two boxes is categorized by a count of the
    number of terminals which denote the type of flow sought: out->in,
    in->out, in->in, out->out.

	(e.g..: The out->in count for a particular box is a count of the
    number of OUT or INOUT terminals from the set of placed modules that
    feed terminals of type IN or INOUT within the box being placed.)
	
	If one of these counts is dominant, then two things occur: the
    counted terminals are used to 'weight' where the new box is to be
    placed w.r.t.. the bounding box of the placed modules, and a 'best-side'
    assignment is made.  Where one count is clearly dominant, then the
    best side is chosen as follows:

	out->in => place the new box to the right of the placed box(es).
	in->out =>   "    "   "   "  "   "  left  "   "     "    "
	in->in =>    "    "   "   "  on top of the placed box(es).
	out->out =>  "    "   "   "  below the placed box(es).



Reference notes:
Summaries:

Pablo [Stok89][Kost89] - design partitioned into set groups of
modules, smaller groups placed to minimize the connection length
between them.  Signal inheritance only addressed in the construction
of simple strings.  (Exactly like GEMS placement.)

VISION [Chun87] - a matrix based, VHDL-oriented gate placer.  Gates
are placed in a grid, with one-level feedback loops, fan-in/ fan-out
conditions specifically located.  Nice results on limited systems.  No
hierarchy, or odd-sized gates handled.  No multi-level feedback. No
Partitioning.  Limited to left-right orientations (column placement is
the distance from the input terminals.)

GEMS [Venk86] - A Heuristic based placement and routing system.
Placement is based roughly on connectivity.  (Same
partitioning/string/box combinations as PABLO) Aimed at RT Level place
& route.


AUTODRAFT [Maj86] - Matrix-style floorplan, based on signal
inheritance.  Partitioning is based on hierarchical information.
Feed-forward and feedback cases are handled separately.
(Cross-coupling is ignored) Nice for well-structured environment,
saving the CC considerations.

IIT [Arya85] - Matrix-style floorplan, with logical placement based on
minimizing channel heights, crossovers.  Detailed placement
(orientation) is set to minimize wire bends.  Paper results.  (Indian
Institute of Technology)

HAL [Ahls84] - An expert system approach, where placement was done by
forming clusters of modules based upon the experts rules.  One such
cluster creation/expansion rule was based on the measure of complexity
of the cluster.  They wrote it off as pretty messy business.  The
results were very wimpy.

AWDDR [May83] - Matrix-style placement arranged to minimize wire bends
and crossovers.  Limited to Left-Right orientations.  Interesting
mathematics to the minimizations.  (Akademie der Wissenshaften der
DDR)

