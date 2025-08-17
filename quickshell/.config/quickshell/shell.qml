// ~/.config/quickshell/shell.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray

Variants {
  model: Quickshell.screens

  delegate: PanelWindow {
    required property var modelData
    screen: modelData

    // ===== Size & theme knobs =====
    implicitHeight: 54
    property int   margin: 10
    property int   pillH: implicitHeight - margin*2   // height of pills
    property int   wsWidth: 44                        // width of each workspace pill
    property int   spacing: 10

    property string fontFamily: "JetBrainsMono Nerd Font"
    property string iconFontFamily: "Noto Color Emoji" // emoji for icons
    property int   wsFont: 17
    property int   clockFont: 17
    property int   weatherFont: 17
    property int   launcherFont: 20

    // POWER BUTTON SIZE
    property real  powerWidthScale: 1.4               // × pillH for width
    property real  powerFontScale: 0.95               // × pillH for font
    property int   powerFont: Math.round(pillH * powerFontScale)
    property int   powerW:    Math.round(pillH * powerWidthScale)

    // THEME
    property color fgColor: "white"
    property color focusColor: "#cc89b4fa"            // active workspace fill (AARRGGBB)
    property color hoverColor: "#2a2a2a"

    // bar background (black w/ adjustable transparency)
    property real  bgAlpha: 0.85
    color: Qt.rgba(0, 0, 0, bgAlpha)

    // commands
    property string launcherCmd: "nwg-drawer"
    property string launcherGlyph: ""
    property int    launcherW: pillH

    property string powerCmd: "nwg-bar -i 64 -f"
    property string powerGlyph: "⏻"

    // spacing tweaks
    property int    launcherWsGap: 12                 // tighter gap
    property real   trayIconScale: 0.72               // ~10% smaller than 0.8

    anchors { top: true; left: true; right: true }

    // ========= LEFT & RIGHT CLUSTERS =========
    RowLayout {
      id: sideClusters
      anchors.fill: parent
      anchors.margins: margin
      spacing: spacing

      // ---- FAR LEFT: Launcher ----
      Rectangle {
        id: launcher
        width: launcherW
        height: pillH
        radius: 10
        color: "transparent"
        Layout.alignment: Qt.AlignVCenter

        Label {
          anchors.centerIn: parent
          text: launcherGlyph
          color: fgColor
          font.family: fontFamily
          font.pixelSize: launcherFont
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: parent.color = hoverColor
          onExited:  parent.color = "transparent"
          onClicked: Quickshell.execDetached(["bash","-lc", launcherCmd])
        }
      }

      // gap between launcher and workspaces
      Item { width: launcherWsGap; height: 1 }

      // ---- LEFT: Workspaces (borderless) ----
      Row {
        id: wsRow
        spacing: 8
        Layout.alignment: Qt.AlignVCenter

        Repeater {
          model: Hyprland.workspaces
          delegate: Rectangle {
            required property var modelData
            width: wsWidth
            height: pillH
            radius: 10
            color: (Hyprland.focusedWorkspace
                    && Hyprland.focusedWorkspace.id === modelData.id)
                   ? focusColor : "transparent"

            Label {
              anchors.centerIn: parent
              text: modelData.name
              color: fgColor
              font.family: fontFamily
              font.pixelSize: wsFont
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: if (parent.color === "transparent") parent.color = hoverColor
              onExited:  if (!(Hyprland.focusedWorkspace
                               && Hyprland.focusedWorkspace.id === modelData.id))
                           parent.color = "transparent"
              onWheel: function(ev) {
                if (ev.angleDelta.y > 0) Hyprland.dispatch("workspace e+1");
                else                      Hyprland.dispatch("workspace e-1");
              }
              onClicked: Hyprland.dispatch("workspace " + modelData.name)
            }
          }
        }
      }

      // ---- single FLEX spacer (pushes right cluster to the edge) ----
      Item { Layout.fillWidth: true }

      // ---- RIGHT-SIDE WIDGETS ----

      // Tray (to the LEFT of sound), borderless
      Rectangle {
        id: trayRect
        radius: 10
        color: "transparent"
        height: pillH
        Layout.alignment: Qt.AlignVCenter
        property int pad: 8
        width: Math.max(pillH, trayRow.implicitWidth + pad*2)

        Row {
          id: trayRow
          anchors.centerIn: parent
          spacing: 6

          Repeater {
            model: SystemTray.items
            delegate: Item {
              width: Math.round(pillH * trayIconScale)   // smaller icons
              height: width

              IconImage {
                anchors.fill: parent
                source: modelData.icon
              }

              MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                onEntered: trayRect.color = hoverColor
                onExited:  trayRect.color = "transparent"
                onClicked: function() {
                  if (modelData && modelData.activate) modelData.activate();
                }
              }

              ToolTip {
                visible: ma.containsMouse
                delay: 400
                text: (modelData.tooltipTitle ?? modelData.title) || ""
              }
            }
          }
        }
      }

      // Audio (emoji icon; borderless)
      Rectangle {
        id: audioRect
        width: Math.max(140, pillH * 2.2)
        height: pillH
        radius: 10
        color: "transparent"
        Layout.alignment: Qt.AlignVCenter

        PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }

        Row {
          anchors.centerIn: parent
          spacing: 10

          Text {
            id: volEmoji
            text: {
              const a = Pipewire.defaultAudioSink?.audio;
              if (!a) return "🔊";
              if (a.muted) return "🔇";
              const v = a.volume;
              if (v < 0.34) return "🔈";
              if (v < 0.67) return "🔉";
              return "🔊";
            }
            font.family: iconFontFamily
            font.pixelSize: Math.round(pillH * 0.6)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            text: {
              const a = Pipewire.defaultAudioSink?.audio;
              const v = a ? a.volume : NaN;
              return Number.isFinite(v) ? Math.round(v * 100) + "%" : "—%";
            }
            color: fgColor
            font.family: fontFamily
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onEntered: parent.color = hoverColor
          onExited:  parent.color = "transparent"

          onClicked: function(ev) {
            const a = Pipewire.defaultAudioSink?.audio;
            if (!a) return;
            if (ev.button === Qt.RightButton) {
              Quickshell.execDetached(["bash","-lc","pavucontrol || helvum || qpwgraph || true"]);
              return;
            }
            a.muted = !a.muted;
          }
          onWheel: function(ev) {
            const a = Pipewire.defaultAudioSink?.audio;
            if (!a) return;
            const step = 0.02;
            a.volume = ev.angleDelta.y > 0 ? Math.min(1.0, a.volume + step)
                                           : Math.max(0.0, a.volume - step);
          }
        }
      }

      // Temps (CPU + NVIDIA)
      Rectangle {
        id: tempsRect
        width: Math.max(180, pillH * 2.6)
        height: pillH
        radius: 10
        color: "transparent"
        Layout.alignment: Qt.AlignVCenter

        // Your fixed CPU sensor path:
        property string cpuTempPath: "/sys/class/hwmon/hwmon3/temp1_input"

        FileView { id: cpuTempFile; path: tempsRect.cpuTempPath; watchChanges: true }

        QtObject { id: gpu; property string text: "" }
        Process {
          id: gpuProc
          command: ["bash","-lc","~/.config/waybar/scripts/nvidia-temp.sh"]
          stdout: StdioCollector { onStreamFinished: gpu.text = text.trim() }
        }
        Timer {
          interval: 3000; repeat: true; running: true
          onTriggered: gpuProc.running = true
          Component.onCompleted: gpuProc.running = true
        }

        Row {
          anchors.centerIn: parent
          spacing: 12

          Text {
            text: {
              const t = cpuTempFile.text();
              if (!t || t.length === 0) return "CPU —°C";
              var n = parseInt(t);
              if (isNaN(n)) return "CPU —°C";
              if (n > 200) n = Math.round(n / 1000);
              return "CPU " + n + "°C";
            }
            color: fgColor
            font.family: fontFamily
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            text: {
              const g = gpu.text;
              if (!g) return "GPU —°C";
              var n = parseInt(g);
              if (isNaN(n)) return "GPU —°C";
              return "GPU " + n + "°C";
            }
            color: fgColor
            font.family: fontFamily
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: parent.color = hoverColor
          onExited:  parent.color = "transparent"
        }
      }

      // Power (nwg-bar)
      Rectangle {
        id: powerBtn
        width: powerW
        height: pillH
        radius: 12
        color: "transparent"
        Layout.alignment: Qt.AlignVCenter

        Text {
          anchors.centerIn: parent
          text: powerGlyph
          color: fgColor
          font.family: fontFamily
          font.pixelSize: powerFont
          font.bold: true
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: parent.color = hoverColor
          onExited:  parent.color = "transparent"
          onClicked: Quickshell.execDetached(["bash","-lc", powerCmd])
        }
      }
    }

    // ========= HARD-CENTERED CLOCK + WEATHER =========
    Row {
      id: centerBlock
      anchors.centerIn: parent
      spacing: 14
      z: 1 // sits above the background; tiny footprint, so it won't block clicks elsewhere

      SystemClock { id: centerClock; precision: SystemClock.Seconds }
      Text {
        text: Qt.formatDateTime(centerClock.date, "ddd MMM d  hh:mm:ss")
        color: fgColor
        font.family: fontFamily
        font.pixelSize: clockFont
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }

      QtObject { id: centerWeatherState; property string text: "—" }
      Process {
        id: centerWeatherProc
        command: ["bash","-lc","~/.config/waybar/scripts/weatherapi.sh"]
        stdout: StdioCollector { onStreamFinished: centerWeatherState.text = text.trim() }
      }
      Timer {
        interval: 5 * 60 * 1000; repeat: true; running: true
        onTriggered: centerWeatherProc.running = true
        Component.onCompleted: centerWeatherProc.running = true
      }
      Text {
        text: centerWeatherState.text
        color: fgColor
        font.family: fontFamily
        font.pixelSize: weatherFont
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
