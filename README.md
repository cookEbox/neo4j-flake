# COMMAND for EXPORTING Cypher

CALL apoc.export.cypher.all("export.cypher", {
  format: "plain",
  useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
});
