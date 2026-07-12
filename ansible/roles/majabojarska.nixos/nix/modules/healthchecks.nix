{ lib, pkgs }:

{
  # Generate a curl command with retry logic for health checks
  #
  # Args:
  #   url: The URL to curl (required)
  #   retry: Number of retries (default: 4)
  #   retryMaxTime: Maximum time for retries in seconds (default: 15)
  #   redirectOutput: Where to redirect output (default: "/dev/null")
  curlHealthCheck = {
    url,
    retry ? 4,
    retryMaxTime ? 15,
    redirectOutput ? "/dev/null",
  }:
    ''
      ${pkgs.curl}/bin/curl \
        --fail-with-body \
        --silent \
        --retry ${toString retry} \
        --retry-max-time ${toString retryMaxTime} \
        --show-error \
          ${url} \
        >${redirectOutput}
    '';
}
