{ ... }:
{
  programs.plasma.panels = [
    {
      location = "right";
      extraSettings = ''
        panel.height = 350;
        panel.alignment = "center";
        panel.hiding = "dodgewindows";
        panel.lengthMode = "fit";
        panel.offset = 0;
        panel.floating = false;

        const panelViews = new ConfigFile("plasmashellrc", "PlasmaViews");
        const panelView = new ConfigFile(panelViews, "Panel " + panel.id);
        const panelDefaults = new ConfigFile(panelView, "Defaults");

        panelView.writeEntry("alignment", 132);
        panelView.writeEntry("panelVisibility", 2);
        panelView.writeEntry("panelLengthMode", 1);
        panelView.writeEntry("floating", 0);
        panelDefaults.writeEntry("thickness", 350);
        panelDefaults.writeEntry("offset", 0);
      '';

      widgets = [
        {
          name = "org.kde.plasma.systemmonitor.memory";
          config = {
            CurrentPreset = "org.kde.plasma.systemmonitor";
            PreloadWeight = 55;
            popupHeight = 234;
            popupWidth = 238;
            showLegend = true;
            Appearance = {
              chartFace = "org.kde.ksysguard.linechart";
              showTitle = false;
              title = "Memory Usage";
            };
            "org.kde.ksysguard.linechart/General".showLegend = true;
            SensorColors = {
              "cpu/all/usage" = "85,170,255";
              "memory/physical/used" = "61,174,233";
              "memory/physical/usedPercent" = "233,120,61";
            };
            SensorLabels = {
              "cpu/all/usage" = "CPU";
              "memory/physical/total" = "Total";
              "memory/physical/used" = "Used";
              "memory/physical/usedPercent" = "RAM";
            };
            Sensors = {
              highPrioritySensorIds = ''["cpu/all/usage","memory/physical/usedPercent"]'';
              lowPrioritySensorIds = ''["memory/physical/used","memory/physical/total"]'';
              totalSensors = ''["memory/physical/usedPercent"]'';
            };
          };
        }
        {
          name = "org.kde.plasma.systemmonitor.net";
          config = {
            CurrentPreset = "org.kde.plasma.systemmonitor";
            showLegend = true;
            Appearance = {
              chartFace = "org.kde.ksysguard.linechart";
              showTitle = false;
              title = "";
            };
            "org.kde.ksysguard.linechart/General".showLegend = true;
            SensorColors = {
              "network/all/download" = "61,174,233";
              "network/all/upload" = "233,120,61";
            };
            Sensors.highPrioritySensorIds = ''["network/all/download","network/all/upload"]'';
          };
        }
        {
          name = "org.kde.plasma.systemmonitor.diskactivity";
          config = {
            CurrentPreset = "org.kde.plasma.systemmonitor";
            showLegend = true;
            Appearance = {
              chartFace = "org.kde.ksysguard.linechart";
              showTitle = false;
              title = "";
            };
            "org.kde.ksysguard.linechart/General".showLegend = true;
            SensorColors = {
              "disk/all/read" = "233,120,61";
              "disk/all/write" = "61,174,233";
            };
            Sensors.highPrioritySensorIds = ''["disk/all/write","disk/all/read"]'';
          };
        }
        {
          name = "org.kde.plasma.systemmonitor.net";
          config = {
            CurrentPreset = "org.kde.plasma.systemmonitor";
            showLegend = true;
            Appearance = {
              chartFace = "org.kde.ksysguard.textonly";
              showTitle = false;
              title = "";
            };
            SensorColors = {
              "cpu/all/averageTemperature" = "61,174,233";
              "network/all/download" = "61,174,233";
              "network/all/upload" = "233,120,61";
              "os/system/uptime" = "233,120,61";
            };
            SensorLabels = {
              "cpu/all/averageTemperature" = "Temp";
              "os/system/uptime" = "Uptime";
            };
            Sensors = {
              highPrioritySensorIds = ''["cpu/all/averageTemperature","os/system/uptime"]'';
              lowPrioritySensorIds = "[]";
              totalSensors = ''["cpu/all/averageTemperature"]'';
            };
            "org.kde.ksysguard.horizontalbars/General" = {
              rangeAuto = false;
            };
          };
        }
      ];
    }
  ];
}
