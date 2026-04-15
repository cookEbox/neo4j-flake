# COMMAND for EXPORTING Cypher

CALL apoc.export.cypher.all(null, {
  stream: true,
  useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
})
YIELD cypherStatements, nodes, relationships, properties, time
RETURN cypherStatements, nodes, relationships, properties, time;
