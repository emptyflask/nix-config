{...}: {
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.bluetooth.enable = false;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.thermald.enable = true;

  services.tlp = {
    enable = true;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_BOOST_ON_AC = 0;

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;

      PCIE_ASPM_ON_AC = "powersave";
      RUNTIME_PM_ON_AC = "auto";

      WIFI_PWR_ON_AC = "on";
    };
  };
}
