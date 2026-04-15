{ ... }:

let
  desktopContainmentId = 1531;
  desktopActivityId = "b8e62697-9cdc-4844-a246-a92998891f25";
  desktopWidth = 1920;
  rightMargin = 16;
  topOffset = 16;
  widgetWidth = 350;
  chartHeight = 200;
  textHeight = 120;
  t = toString;
  containmentPath = "Containments/${t desktopContainmentId}";
  appletPath = id: "${containmentPath}/Applets/${t id}";
  widgetX = desktopWidth - widgetWidth - rightMargin;
  itemGeometries = builtins.concatStringsSep "" [
    "Applet-1527:${t widgetX},${t topOffset},${t widgetWidth},${t chartHeight},0;"
    "Applet-1528:${t widgetX},${t (topOffset + chartHeight)},${t widgetWidth},${t chartHeight},0;"
    "Applet-1529:${t widgetX},${t (topOffset + chartHeight * 2)},${t widgetWidth},${t chartHeight},0;"
    "Applet-1530:${t widgetX},${t (topOffset + chartHeight * 3)},${t widgetWidth},${t textHeight},0;"
  ];
in
{
  programs.plasma.configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
    "${containmentPath}" = {
      "ItemGeometries-1920x1080" = itemGeometries;
      ItemGeometriesHorizontal = itemGeometries;
      activityId = desktopActivityId;
      formfactor = 0;
      immutability = 1;
      lastScreen = 0;
      location = 0;
      plugin = "org.kde.plasma.folder";
      wallpaperplugin = "org.kde.image";
    };

    "${appletPath 1527}" = {
      immutability = 1;
      plugin = "org.kde.plasma.systemmonitor";
    };

    "${appletPath 1527}/Configuration" = {
      CurrentPreset = "org.kde.plasma.systemmonitor";
      PreloadWeight = 55;
      popupHeight = 234;
      popupWidth = 238;
      showLegend = true;
    };

    "${appletPath 1527}/Configuration/Appearance" = {
      chartFace = "org.kde.ksysguard.linechart";
      showTitle = false;
      title = "Memory Usage";
    };

    "${appletPath 1527}/Configuration/SensorColors" = {
      "cpu/all/usage" = "85,170,255";
      "memory/physical/used" = "61,174,233";
      "memory/physical/usedPercent" = "233,120,61";
    };

    "${appletPath 1527}/Configuration/SensorLabels" = {
      "cpu/all/usage" = "CPU";
      "memory/physical/total" = "Total";
      "memory/physical/used" = "Used";
      "memory/physical/usedPercent" = "RAM";
    };

    "${appletPath 1527}/Configuration/Sensors" = {
      highPrioritySensorIds = ''["cpu/all/usage","memory/physical/usedPercent"]'';
      lowPrioritySensorIds = ''["memory/physical/used","memory/physical/total"]'';
      totalSensors = ''["memory/physical/usedPercent"]'';
    };

    "${appletPath 1527}/Configuration/org.kde.ksysguard.linechart/General".showLegend = true;

    "${appletPath 1528}" = {
      immutability = 1;
      plugin = "org.kde.plasma.systemmonitor";
    };

    "${appletPath 1528}/Configuration" = {
      CurrentPreset = "org.kde.plasma.systemmonitor";
      showLegend = true;
    };

    "${appletPath 1528}/Configuration/Appearance" = {
      chartFace = "org.kde.ksysguard.linechart";
      showTitle = false;
      title = "";
    };

    "${appletPath 1528}/Configuration/SensorColors" = {
      "network/all/download" = "61,174,233";
      "network/all/upload" = "233,120,61";
    };

    "${appletPath 1528}/Configuration/SensorLabels" = {
      "network/all/download" = "Download";
      "network/all/upload" = "Upload";
    };

    "${appletPath 1528}/Configuration/Sensors".highPrioritySensorIds =
      ''["network/all/download","network/all/upload"]'';

    "${appletPath 1528}/Configuration/org.kde.ksysguard.linechart/General".showLegend = true;

    "${appletPath 1529}" = {
      immutability = 1;
      plugin = "org.kde.plasma.systemmonitor";
    };

    "${appletPath 1529}/Configuration" = {
      CurrentPreset = "org.kde.plasma.systemmonitor";
      showLegend = true;
    };

    "${appletPath 1529}/Configuration/Appearance" = {
      chartFace = "org.kde.ksysguard.linechart";
      showTitle = false;
      title = "";
    };

    "${appletPath 1529}/Configuration/SensorColors" = {
      "disk/all/read" = "233,120,61";
      "disk/all/write" = "61,174,233";
    };

    "${appletPath 1529}/Configuration/SensorLabels" = {
      "disk/all/read" = "Read";
      "disk/all/write" = "Write";
    };

    "${appletPath 1529}/Configuration/Sensors".highPrioritySensorIds =
      ''["disk/all/write","disk/all/read"]'';

    "${appletPath 1529}/Configuration/org.kde.ksysguard.linechart/General".showLegend = true;

    "${appletPath 1530}" = {
      immutability = 1;
      plugin = "org.kde.plasma.systemmonitor";
    };

    "${appletPath 1530}/Configuration" = {
      CurrentPreset = "org.kde.plasma.systemmonitor";
      showLegend = true;
    };

    "${appletPath 1530}/Configuration/Appearance" = {
      chartFace = "org.kde.ksysguard.textonly";
      showTitle = false;
      title = "";
    };

    "${appletPath 1530}/Configuration/SensorColors" = {
      "cpu/all/averageTemperature" = "61,174,233";
      "os/system/uptime" = "233,120,61";
    };

    "${appletPath 1530}/Configuration/SensorLabels" = {
      "cpu/all/averageTemperature" = "Temp";
      "os/system/uptime" = "Uptime";
    };

    "${appletPath 1530}/Configuration/Sensors" = {
      highPrioritySensorIds = ''["cpu/all/averageTemperature","os/system/uptime"]'';
      lowPrioritySensorIds = "[]";
      totalSensors = ''["cpu/all/averageTemperature"]'';
    };

    "${appletPath 1530}/Configuration/org.kde.ksysguard.textonly/General".groupByTotal = false;
  };
}
