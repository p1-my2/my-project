class NetworkNodeModel {
  final String id;
  final int inDegree;
  final int outDegree;
  final int degree;
  final double degreeCentrality;
  final int rank;
  final bool isMisinformationHub;

  NetworkNodeModel({
    required this.id,
    required this.inDegree,
    required this.outDegree,
    required this.degree,
    required this.degreeCentrality,
    required this.rank,
    this.isMisinformationHub = false,
  });

  factory NetworkNodeModel.fromJson(Map<String, dynamic> json, int rank, {bool isMisinformation = false}) {
    final inDeg = json['inDegree'] is int ? json['inDegree'] as int : int.tryParse(json['inDegree'].toString()) ?? 0;
    final outDeg = json['outDegree'] is int ? json['outDegree'] as int : int.tryParse(json['outDegree'].toString()) ?? 0;
    final deg = json['degree'] is int ? json['degree'] as int : (inDeg + outDeg);
    final cent = json['degreeCentrality'] is num ? (json['degreeCentrality'] as num).toDouble() : double.tryParse(json['degreeCentrality'].toString()) ?? 0.0;

    return NetworkNodeModel(
      id: json['id']?.toString() ?? '',
      inDegree: inDeg,
      outDegree: outDeg,
      degree: deg,
      degreeCentrality: cent,
      rank: rank,
      isMisinformationHub: isMisinformation,
    );
  }

  double get influenceScore => (degreeCentrality * 100).clamp(0.0, 100.0);
  double get reachScore => (degreeCentrality * 1000 + outDegree * 50.0);
}

class NetworkEdgeModel {
  final String source;
  final String target;
  final String type;
  final String? postId;

  NetworkEdgeModel({
    required this.source,
    required this.target,
    required this.type,
    this.postId,
  });

  factory NetworkEdgeModel.fromJson(Map<String, dynamic> json) {
    return NetworkEdgeModel(
      source: json['source']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      type: json['type']?.toString() ?? 'interaction',
      postId: json['postId']?.toString(),
    );
  }
}

class NetworkDataModel {
  final int totalNodes;
  final int totalEdges;
  final double density;
  final int totalPosts;
  final List<NetworkNodeModel> nodes;
  final List<NetworkEdgeModel> edges;

  NetworkDataModel({
    required this.totalNodes,
    required this.totalEdges,
    required this.density,
    required this.totalPosts,
    required this.nodes,
    required this.edges,
  });

  factory NetworkDataModel.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List? ?? [];
    final rawEdges = json['edges'] as List? ?? [];

    final nodesList = <NetworkNodeModel>[];
    for (int i = 0; i < rawNodes.length; i++) {
      nodesList.add(NetworkNodeModel.fromJson(rawNodes[i] as Map<String, dynamic>, i + 1));
    }

    final edgesList = rawEdges.map((e) => NetworkEdgeModel.fromJson(e as Map<String, dynamic>)).toList();

    return NetworkDataModel(
      totalNodes: json['totalNodes'] is int ? json['totalNodes'] as int : int.tryParse(json['totalNodes'].toString()) ?? nodesList.length,
      totalEdges: json['totalEdges'] is int ? json['totalEdges'] as int : int.tryParse(json['totalEdges'].toString()) ?? edgesList.length,
      density: json['density'] is num ? (json['density'] as num).toDouble() : double.tryParse(json['density'].toString()) ?? 0.0,
      totalPosts: json['totalPosts'] is int ? json['totalPosts'] as int : int.tryParse(json['totalPosts'].toString()) ?? 0,
      nodes: nodesList,
      edges: edgesList,
    );
  }

  double get averageDegree => totalNodes > 0 ? (2.0 * totalEdges / totalNodes) : 0.0;
  NetworkNodeModel? get topInfluencer => nodes.isNotEmpty ? nodes.first : null;
}

class NetworkFilterModel {
  final String searchQuery;
  final int minDegree;
  final int maxDegree;
  final String interactionType;
  final bool showOnlyMisinformation;

  NetworkFilterModel({
    this.searchQuery = '',
    this.minDegree = 0,
    this.maxDegree = 1000,
    this.interactionType = 'All',
    this.showOnlyMisinformation = false,
  });

  NetworkFilterModel copyWith({
    String? searchQuery,
    int? minDegree,
    int? maxDegree,
    String? interactionType,
    bool? showOnlyMisinformation,
  }) {
    return NetworkFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      minDegree: minDegree ?? this.minDegree,
      maxDegree: maxDegree ?? this.maxDegree,
      interactionType: interactionType ?? this.interactionType,
      showOnlyMisinformation: showOnlyMisinformation ?? this.showOnlyMisinformation,
    );
  }
}
