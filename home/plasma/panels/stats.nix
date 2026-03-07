{ ... }:
{
  programs.plasma.panels = [
    {
      alignment = "center";
      location = "right";
      hiding = "dodgewindows";
      lengthMode = "fit";
      height = 1920 / 5;

      widgets = [
        {
          systemMonitor = {
            title = "Memory Usage";
            showTitle = false;
            showLegend = true;
            displayStyle = "org.kde.ksysguard.linechart";
            sensors = [
              {
                name = "cpu/all/usage";
                color = "85,170,255";
                label = "CPU";
              }
              {
                name = "memory/physical/usedPercent";
                color = "233,120,61";
                label = "RAM";
              }
            ];
            settings = {
              SensorColors."memory/physical/used" = "61,174,233";
              SensorLabels."memory/physical/used" = "Used";
              SensorLabels."memory/physical/total" = "Total";
              Sensors = {
                highPrioritySensorIds = ''["cpu/all/usage","memory/physical/usedPercent"]'';
                lowPrioritySensorIds = ''["memory/physical/used","memory/physical/total"]'';
                totalSensors = ''["memory/physical/usedPercent"]'';
              };
            };
          };
        }
        {
          systemMonitor = {
            showTitle = false;
            showLegend = true;
            displayStyle = "org.kde.ksysguard.linechart";
            sensors = [
              {
                name = "network/all/download";
                color = "61,174,233";
                label = "Download";
              }
              {
                name = "network/all/upload";
                color = "233,120,61";
                label = "Upload";
              }
            ];
            settings = {
              SensorColors."os/system/hostname" = "233,140,61";
              Sensors.highPrioritySensorIds = ''["network/all/download","network/all/upload"]'';
            };
          };
        }
        {
          systemMonitor = {
            showTitle = false;
            showLegend = true;
            displayStyle = "org.kde.linebars";
            sensors = [
              {
                name = "cpu/all/averageTemperature";
                color = "61,174,233";
                label = "Temp";
              }
              {
                name = "os/system/uptime";
                color = "233,120,61";
                label = "Uptime";
              }
            ];
            settings = {
              SensorColors."network/all/download" = "61,174,233";
              SensorColors."network/all/upload" = "233,120,61";
              Sensors = {
                highPrioritySensorIds = ''["cpu/all/averageTemperature","os/system/uptime"]'';
                lowPrioritySensorIds = "[]";
                totalSensors = ''["cpu/all/averageTemperature"]'';
              };
              "org.kde.linebars/General".rangeAuto = false;
            };
          };
        }
        {
          systemMonitor = {
            showTitle = false;
            showLegend = true;
            displayStyle = "org.kde.ksysguard.linechart";
            sensors = [
              {
                name = "disk/all/write";
                color = "61,174,233";
                label = "Write";
              }
              {
                name = "disk/all/read";
                color = "233,120,61";
                label = "Read";
              }
            ];
            settings.Sensors.highPrioritySensorIds = ''["disk/all/write","disk/all/read"]'';
          };
        }
      ];
    }
  ];
}
