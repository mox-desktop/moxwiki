{
  dockerTools,
  buildEnv,
  mdbook,
  runCommand,
}:
dockerTools.buildImage {
  name = "moxwiki";
  tag = "latest";
  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      mdbook
      (runCommand "moxwiki-files" { } ''
        mkdir -p $out/app
        cp -r ${./../book.toml} $out/app/book.toml
        cp -r ${./../src} $out/app/src
      '')
    ];
    pathsToLink = [
      "/bin"
      "/app"
    ];
  };
  config = {
    Cmd = [
      "mdbook"
      "serve"
      "--hostname"
      "0.0.0.0"
      "--port"
      "3000"
    ];
    WorkingDir = "/app";
    ExposedPorts = {
      "3000/tcp" = { };
    };
  };
}
