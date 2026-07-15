{ config }:
let
  pveExporterTarget = "127.0.0.1:${toString config.services.prometheus.exporters.pve.port}";
in
{
  jobName,
  cfgName,
  target,
}:
{
  job_name = jobName;
  metrics_path = "/pve";
  params = {
    module = [ cfgName ];
    inherit target;
  };
  static_configs = [
    {
      targets = [ pveExporterTarget ];
    }
  ];
  metric_relabel_configs = [
    {
      source_labels = [ "__address__" ];
      target_label = "__param_target";
    }
    {
      source_labels = [ "__param_target" ];
      target_label = "instance";
    }
    {
      target_label = "__address__";
      replacement = pveExporterTarget;
    }
  ];
}
