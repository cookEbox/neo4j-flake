{
  description = "Simple Neo4j playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        neo4jUp = pkgs.writeShellApplication {
          name = "neo4j-up";
          runtimeInputs = with pkgs; [ docker coreutils ];
          text = ''
            set -eu

            mkdir -p .neo4j/data/import

            docker run -d \
              --rm \
              --name neo4j-play \
              -p 7474:7474 \
              -p 7687:7687 \
              -e NEO4J_AUTH=neo4j/testpassword123 \
              -e NEO4JLABS_PLUGINS='["apoc"]' \
              -e NEO4J_apoc_export_file_enabled=true \
              -e NEO4J_server_directories_import=/data/import \
              -v "$PWD/.neo4j/data:/data" \
              neo4j
          '';
        };

        neo4jDown = pkgs.writeShellApplication {
          name = "neo4j-down";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            set -eu
            docker stop neo4j-play || true
          '';
        };

        neo4jLogs = pkgs.writeShellApplication {
          name = "neo4j-logs";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            set -eu
            docker logs -f neo4j-play
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            docker
            neo4jUp
            neo4jDown
            neo4jLogs
            curl
          ];

          shellHook = ''
            echo "Neo4j playground shell"
            echo "Run: neo4j-up"
            echo "Stop: neo4j-down"
            echo "Logs: neo4j-logs"
            echo "Browser: http://localhost:7474"
            echo "Login: neo4j / testpassword123"
          '';
        };
      });
}
