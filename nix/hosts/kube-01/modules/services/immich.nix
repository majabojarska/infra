{ pkgs, config, ... }:
let
  dbName = "immich";
  dbUser = "postgres";
  dockerNetwork = "immich";

  pathStorage = "/storage/kubernetes/immich-new/";
  pathPhotos = "${pathStorage}/photos";
  pathDb = "${pathStorage}/postgres";
  pathModelCache = "${pathStorage}/model-cache";
in
{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.backend = "docker";

  age.secrets.immich-env = {
    file = ../../secrets/immich.env.age;
    owner = "immich";
    group = "immich";
    mode = "0400";
  };

  virtualisation.oci-containers.containers = {

    # immich-server = {
    #   image = "ghcr.io/immich-app/immich-server:v3.1.0";
    #   autoStart = true;
    #   ports = [
    #     "2283:2283"
    #   ];
    #   environmentFiles = [
    #     config.age.secrets.immich-env.path
    #   ];
    #   environment = {
    #     TZ = "Europe/Warsaw";
    #   };
    #   volumes = [
    #     "${locationUpload}:/data"
    #     "/etc/localtime:/etc/localtime:ro"
    #   ];
    #   dependsOn = [
    #     "redis"
    #     "database"
    #   ];
    #   extraOptions = [
    #     "--name=immich_server"
    #     # Uncomment for Intel/AMD VAAPI transcoding
    #     "--device=/dev/dri:/dev/dri"
    #   ];
    #   cmd = [
    #     "start.sh"
    #     "immich"
    #   ];
    # };

    # immich-machine-learning = {
    #   image = "ghcr.io/immich-app/immich-machine-learning:v3.1.0";
    #   autoStart = true;
    #   environmentFiles = [
    #     config.age.secrets.immich-env.path
    #   ];
    #   volumes = [
    #     "${locationModelCache}:/cache"
    #   ];
    #   extraOptions = [
    #     "--name=immich_machine_learning"
    #   ];
    # };

    redis = {
      image = "valkey/valkey:9@sha256:8e8d64b405ce18f41b8e5ee20aa4687a8ed0022d1298f2ce31cdcf3a76e09411";
      autoStart = true;
      extraOptions = [
        "--name=immich_redis"
      ];
      cmd = [
        "sh"
        "-c"
        "valkey-server"
      ];
    };

    database = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      autoStart = true;
      environmentFiles = [
        config.age.secrets.immich-env.path
      ];
      environment = {
        POSTGRES_DB = dbName;
        POSTGRES_USER = dbUser;
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      volumes = [
        "${pathDb}/:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--name=immich_postgres"
        "--shm-size=128m"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathStorage} 0750 immich immich -"
    "d ${pathDb} 0750 immich immich -"
    "d ${pathPhotos} 0750 immich immich -"
    "d ${pathModelCache} 0750 immich immich -"
  ];
}
