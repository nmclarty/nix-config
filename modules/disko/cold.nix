{
  boot.zfs.extraPools = [ "cold" ];
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "cold";
            };
          };
        };
      };

      two = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "cold";
            };
          };
        };
      };
    };

    zpool = {
      cold = {
        type = "zpool";
        mode = "mirror";
        options.ashift = "12";
        rootFsOptions = {
          compression = "lz4";
          xattr = "sa";
          mountpoint = "none";
          # encryption
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///run/secrets/zfs/cold";
        };
        datasets = {
          backup = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          shares = {
            type = "zfs_fs";
            options.mountpoint = "/cold/shares";
          };
          vault = {
            type = "zfs_fs";
            options.mountpoint = "/cold/vault";
          };
        };
      };
    };
  };
}
