import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        Layout.minimumWidth:    580
        Layout.minimumHeight:   520
        Layout.preferredWidth:  820
        Layout.preferredHeight: 620

        // ── Layout constants ─────────────────────────────────────────────
        readonly property int navH:      30
        readonly property int headerH:   22
        readonly property int cellGap:    4
        readonly property int margin:     8
        readonly property int barGap:     2

        // ── Navigation ───────────────────────────────────────────────────
        property int weekOffset: 0

        // ── Series colours ───────────────────────────────────────────────
        readonly property var seriesCfg: ({
            "F1":   { color: "#E8002D" },
            "F2":   { color: "#FF6B35" },
            "F3":   { color: "#FFD166" },
            "WEC":  { color: "#00B4D8" },
            "IMSA": { color: "#06D6A0" },
            "NLS":  { color: "#A663CC" },
            "GTWC": { color: "#F4A261" },
            "WRC":  { color: "#EF476F" }
        })

        // ── Event data ───────────────────────────────────────────────────
        readonly property var events: [
            // ── January ──────────────────────────────────────────────────
            { series:"IMSA", location:"Daytona",     eventType:"24h Race",   flag:"🇺🇸", start:makeDate(2026,1,22), end:makeDate(2026,1,25) },
            { series:"WRC",  location:"Monte Carlo", eventType:"Rally",      flag:"🇲🇨", start:makeDate(2026,1,22), end:makeDate(2026,1,25) },

            // ── February ─────────────────────────────────────────────────
            { series:"WRC",  location:"Sweden",      eventType:"Rally",      flag:"🇸🇪", start:makeDate(2026,2,12), end:makeDate(2026,2,15) },

            // ── March ────────────────────────────────────────────────────
            { series:"WEC",  location:"Qatar",       eventType:"Prologue",   flag:"🇶🇦", start:makeDate(2026,3,13), end:makeDate(2026,3,17) },
            { series:"IMSA", location:"Sebring",     eventType:"12h Race",   flag:"🇺🇸", start:makeDate(2026,3,14), end:makeDate(2026,3,15) },
            { series:"WRC",  location:"Mexico",      eventType:"Rally",      flag:"🇲🇽", start:makeDate(2026,3,19), end:makeDate(2026,3,23) },
            { series:"F1",   location:"Melbourne",   eventType:"Grand Prix", flag:"🇦🇺", start:makeDate(2026,3,20), end:makeDate(2026,3,22) },
            { series:"F2",   location:"Melbourne",   eventType:"Round 2",    flag:"🇦🇺", start:makeDate(2026,3,21), end:makeDate(2026,3,22) },
            { series:"NLS",  location:"Nürburgring", eventType:"Round 1",    flag:"🇩🇪", start:makeDate(2026,3,21), end:makeDate(2026,3,21) },
            { series:"F1",   location:"Bahrain",     eventType:"Grand Prix", flag:"🇧🇭", start:makeDate(2026,3,27), end:makeDate(2026,3,29) },
            { series:"F2",   location:"Bahrain",     eventType:"Round 3",    flag:"🇧🇭", start:makeDate(2026,3,28), end:makeDate(2026,3,29) },
            { series:"F3",   location:"Bahrain",     eventType:"Round 3",    flag:"🇧🇭", start:makeDate(2026,3,28), end:makeDate(2026,3,29) },

            // ── April ────────────────────────────────────────────────────
            { series:"WEC",  location:"Portimão",    eventType:"6h Race",    flag:"🇵🇹", start:makeDate(2026,4,4),  end:makeDate(2026,4,5)  },
            { series:"GTWC", location:"Paul Ricard", eventType:"3h Race",    flag:"🇫🇷", start:makeDate(2026,4,4),  end:makeDate(2026,4,5)  },
            { series:"IMSA", location:"Mid-Ohio",    eventType:"4h Race",    flag:"🇺🇸", start:makeDate(2026,4,5),  end:makeDate(2026,4,5)  },
            { series:"WRC",  location:"Croatia",     eventType:"Rally",      flag:"🇭🇷", start:makeDate(2026,4,9),  end:makeDate(2026,4,12) },
            { series:"F1",   location:"Shanghai",    eventType:"Grand Prix", flag:"🇨🇳", start:makeDate(2026,4,10), end:makeDate(2026,4,12) },
            { series:"F2",   location:"Shanghai",    eventType:"Round 4",    flag:"🇨🇳", start:makeDate(2026,4,11), end:makeDate(2026,4,12) },
            { series:"NLS",  location:"Nürburgring", eventType:"Round 2",    flag:"🇩🇪", start:makeDate(2026,4,11), end:makeDate(2026,4,11) },
            { series:"F1",   location:"Jeddah",      eventType:"Grand Prix", flag:"🇸🇦", start:makeDate(2026,4,17), end:makeDate(2026,4,19) },
            { series:"F2",   location:"Jeddah",      eventType:"Round 5",    flag:"🇸🇦", start:makeDate(2026,4,18), end:makeDate(2026,4,19) },
            { series:"WEC",  location:"Imola",       eventType:"6h Race",    flag:"🇮🇹", start:makeDate(2026,4,17), end:makeDate(2026,4,19) },
            { series:"GTWC", location:"Magny-Cours", eventType:"3h Race",    flag:"🇫🇷", start:makeDate(2026,4,24), end:makeDate(2026,4,26) },

            // ── May ──────────────────────────────────────────────────────
            { series:"F1",   location:"Miami",       eventType:"Grand Prix", flag:"🇺🇸", start:makeDate(2026,5,1),  end:makeDate(2026,5,3)  },
            { series:"F2",   location:"Miami",       eventType:"Round 6",    flag:"🇺🇸", start:makeDate(2026,5,2),  end:makeDate(2026,5,3)  },
            { series:"WEC",  location:"Spa",         eventType:"6h Race",    flag:"🇧🇪", start:makeDate(2026,5,8),  end:makeDate(2026,5,10) },
            { series:"NLS",  location:"Nürburgring", eventType:"Round 3",    flag:"🇩🇪", start:makeDate(2026,5,9),  end:makeDate(2026,5,9)  },
            { series:"F1",   location:"Monaco",      eventType:"Grand Prix", flag:"🇲🇨", start:makeDate(2026,5,22), end:makeDate(2026,5,24) },
            { series:"F2",   location:"Monaco",      eventType:"Round 7",    flag:"🇲🇨", start:makeDate(2026,5,23), end:makeDate(2026,5,24) },
            { series:"NLS",  location:"Nürburgring", eventType:"24h Race",   flag:"🇩🇪", start:makeDate(2026,5,23), end:makeDate(2026,5,25) },
            { series:"WRC",  location:"Portugal",    eventType:"Rally",      flag:"🇵🇹", start:makeDate(2026,5,21), end:makeDate(2026,5,24) },
            { series:"GTWC", location:"Misano",      eventType:"3h Race",    flag:"🇮🇹", start:makeDate(2026,5,30), end:makeDate(2026,5,31) },

            // ── June ─────────────────────────────────────────────────────
            { series:"WRC",  location:"Sardinia",    eventType:"Rally",      flag:"🇮🇹", start:makeDate(2026,6,4),  end:makeDate(2026,6,7)  },
            { series:"NLS",  location:"Nürburgring", eventType:"Round 4",    flag:"🇩🇪", start:makeDate(2026,6,6),  end:makeDate(2026,6,6)  },
            { series:"IMSA", location:"Detroit",     eventType:"2h40 Race",  flag:"🇺🇸", start:makeDate(2026,6,6),  end:makeDate(2026,6,7)  },
            { series:"F1",   location:"Barcelona",   eventType:"Grand Prix", flag:"🇪🇸", start:makeDate(2026,6,12), end:makeDate(2026,6,14) },
            { series:"F2",   location:"Barcelona",   eventType:"Round 8",    flag:"🇪🇸", start:makeDate(2026,6,13), end:makeDate(2026,6,14) },
            { series:"WEC",  location:"Le Mans",     eventType:"24h Race",   flag:"🇫🇷", start:makeDate(2026,6,13), end:makeDate(2026,6,14) },
            { series:"F1",   location:"Montreal",    eventType:"Grand Prix", flag:"🇨🇦", start:makeDate(2026,6,19), end:makeDate(2026,6,21) },
            { series:"F2",   location:"Montreal",    eventType:"Round 9",    flag:"🇨🇦", start:makeDate(2026,6,20), end:makeDate(2026,6,21) },
            { series:"IMSA", location:"Watkins Glen",eventType:"6h Race",    flag:"🇺🇸", start:makeDate(2026,6,26), end:makeDate(2026,6,28) },
            { series:"GTWC", location:"Brands Hatch",eventType:"3h Race",    flag:"🇬🇧", start:makeDate(2026,6,27), end:makeDate(2026,6,28) },

            // ── July ─────────────────────────────────────────────────────
            { series:"WRC",  location:"Kenya",       eventType:"Rally",      flag:"🇰🇪", start:makeDate(2026,7,2),  end:makeDate(2026,7,5)  },
            { series:"NLS",  location:"Nürburgring", eventType:"Round 5",    flag:"🇩🇪", start:makeDate(2026,7,4),  end:makeDate(2026,7,4)  },
            { series:"F1",   location:"Spielberg",   eventType:"Grand Prix", flag:"🇦🇹", start:makeDate(2026,7,3),  end:makeDate(2026,7,5)  },
            { series:"F1",   location:"Silverstone", eventType:"Grand Prix", flag:"🇬🇧", start:makeDate(2026,7,17), end:makeDate(2026,7,19) },
            { series:"F2",   location:"Silverstone", eventType:"Round 10",   flag:"🇬🇧", start:makeDate(2026,7,18), end:makeDate(2026,7,19) },
            { series:"IMSA", location:"Lime Rock",   eventType:"2h45 Race",  flag:"🇺🇸", start:makeDate(2026,7,18), end:makeDate(2026,7,19) },
            { series:"GTWC", location:"Zandvoort",   eventType:"3h Race",    flag:"🇳🇱", start:makeDate(2026,7,18), end:makeDate(2026,7,19) },
            { series:"WEC",  location:"São Paulo",   eventType:"6h Race",    flag:"🇧🇷", start:makeDate(2026,7,10), end:makeDate(2026,7,12) },
            { series:"F1",   location:"Budapest",    eventType:"Grand Prix", flag:"🇭🇺", start:makeDate(2026,7,31), end:makeDate(2026,8,2)  },

            // ── August ───────────────────────────────────────────────────
            { series:"NLS",  location:"Nürburgring", eventType:"Round 6",    flag:"🇩🇪", start:makeDate(2026,8,1),  end:makeDate(2026,8,1)  },
            { series:"WRC",  location:"Finland",     eventType:"Rally",      flag:"🇫🇮", start:makeDate(2026,8,6),  end:makeDate(2026,8,9)  },
            { series:"IMSA", location:"Road America",eventType:"4h Race",    flag:"🇺🇸", start:makeDate(2026,8,7),  end:makeDate(2026,8,9)  },
            { series:"F1",   location:"Spa",         eventType:"Grand Prix", flag:"🇧🇪", start:makeDate(2026,8,28), end:makeDate(2026,8,30) },
            { series:"F2",   location:"Spa",         eventType:"Round 11",   flag:"🇧🇪", start:makeDate(2026,8,29), end:makeDate(2026,8,30) }
        ]

        function makeDate(y, m, d) {
            var dt = new Date(y, m - 1, d)
            dt.setHours(0, 0, 0, 0)
            return dt
        }

        // ── Date helpers ─────────────────────────────────────────────────
        readonly property var today: {
            var d = new Date()
            d.setHours(0, 0, 0, 0)
            return d
        }

        readonly property var gridStart: {
            var d   = new Date(today)
            var dow = d.getDay()
            d.setDate(d.getDate() + (dow === 0 ? -6 : 1 - dow) - 7 + weekOffset * 7)
            return d
        }

        function weekStartDate(wi) {
            var d = new Date(gridStart)
            d.setDate(d.getDate() + wi * 7)
            return d
        }
        function weekEndDate(wi) {
            var d = weekStartDate(wi)
            d.setDate(d.getDate() + 6)
            return d
        }
        function cellDate(wi, di) {
            var d = new Date(gridStart)
            d.setDate(d.getDate() + wi * 7 + di)
            return d
        }
        function isToday(d)        { return d.toDateString() === today.toDateString() }
        function isCurrentMonth(d) { return d.getMonth() === today.getMonth() }
        function daysDiff(a, b)    { return Math.round((b - a) / 86400000) }

        // Which grid row index contains today (-1 if not visible)
        readonly property int currentGridRow: {
            for (var i = 0; i < 4; i++) {
                if (today >= weekStartDate(i) && today <= weekEndDate(i)) return i
            }
            return -1
        }

        function navLabel() {
            var s = gridStart
            var e = new Date(gridStart)
            e.setDate(e.getDate() + 27)
            if (s.getMonth() === e.getMonth() && s.getFullYear() === e.getFullYear())
                return Qt.formatDate(s, "MMMM yyyy")
            if (s.getFullYear() === e.getFullYear())
                return Qt.formatDate(s, "MMM") + " – " + Qt.formatDate(e, "MMM yyyy")
            return Qt.formatDate(s, "MMM yyyy") + " – " + Qt.formatDate(e, "MMM yyyy")
        }

        // ── Series helpers ────────────────────────────────────────────────
        function seriesColor(s) { return seriesCfg[s] ? seriesCfg[s].color : "#888888" }
        function contrastColor(hex) {
            var r = parseInt(hex.slice(1,3), 16)
            var g = parseInt(hex.slice(3,5), 16)
            var b = parseInt(hex.slice(5,7), 16)
            return (0.299*r + 0.587*g + 0.114*b)/255 > 0.55 ? "#000000" : "#ffffff"
        }

        // ── Event layout for a week ───────────────────────────────────────
        function eventsForWeek(wi) {
            var wS = weekStartDate(wi)
            var wE = weekEndDate(wi)
            var result = []
            for (var i = 0; i < events.length; i++) {
                var ev = events[i]
                if (ev.end < wS || ev.start > wE) continue
                var sc = Math.max(0, daysDiff(wS, ev.start))
                var ec = Math.min(6, daysDiff(wS, ev.end))
                result.push({
                    series:       ev.series,
                    location:     ev.location,
                    eventType:    ev.eventType,
                    flag:         ev.flag,
                    startCol:     sc,
                    endCol:       ec,
                    spanCols:     ec - sc + 1,
                    clippedLeft:  ev.start < wS,
                    clippedRight: ev.end   > wE,
                    lane:         0
                })
            }
            result.sort(function(a,b) {
                return a.startCol !== b.startCol ? a.startCol - b.startCol : b.spanCols - a.spanCols
            })
            var laneEnds = []
            for (var j = 0; j < result.length; j++) {
                var e = result[j]
                var placed = false
                for (var lane = 0; lane < laneEnds.length; lane++) {
                    if (laneEnds[lane] < e.startCol) {
                        laneEnds[lane] = e.endCol; e.lane = lane; placed = true; break
                    }
                }
                if (!placed) { e.lane = laneEnds.length; laneEnds.push(e.endCol) }
            }
            return result
        }

        // ── Root layout ───────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: margin
            spacing:         cellGap

            // ── ▲ Previous week ───────────────────────────────────────────
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH
                radius: 4
                color: prevArea.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                opacity: prevArea.containsMouse ? 0.5 : 0.6

                Text {
                    anchors.centerIn: parent
                    text: "▲"
                    font.pixelSize: 13
                    color: Kirigami.Theme.textColor
                }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: weekOffset--
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // ── Date label + Today ────────────────────────────────────────
            Item {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH

                Text {
                    anchors.centerIn: parent
                    text: navLabel()
                    font.pixelSize: 12
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }

                Rectangle {
                    visible: weekOffset !== 0
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: todayLabel.implicitWidth + 12
                    height: navH - 6
                    radius: 4
                    color: Kirigami.Theme.highlightColor
                    opacity: todayArea.containsMouse ? 1.0 : 0.6
                    Text {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "Today"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }
                    MouseArea {
                        id: todayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: weekOffset = 0
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // ── Day-of-week header ─────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:       true
                Layout.preferredHeight: headerH
                spacing: cellGap

                Repeater {
                    model: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                    delegate: Item {
                        Layout.fillWidth:       true
                        Layout.preferredHeight: headerH
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            color: index >= 5 ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                            opacity: 0.6
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.textColor
                opacity: 0.15
            }

            // ── 4 week rows ───────────────────────────────────────────────
            Repeater {
                model: 4
                delegate: Item {
                    id: weekRow
                    readonly property int weekIdx: index
                    readonly property var weekEvs: eventsForWeek(index)

                    Layout.fillWidth:    true
                    Layout.fillHeight:   true
                    Layout.minimumHeight: 70

                    readonly property bool isPast:    weekEndDate(weekRow.weekIdx) < today
                    readonly property bool isCurrent: weekRow.weekIdx === currentGridRow
                    readonly property bool isNext:    currentGridRow >= 0 && weekRow.weekIdx === currentGridRow + 1

                    // Dynamic bar sizing based on actual row height
                    readonly property real dynBarTopOffset: Math.max(18, height * 0.22)
                    readonly property real dynBarH:         Math.max(14, height * 0.17)
                    readonly property real dynFontPx:       Math.max(10, Math.min(14, height * 0.13))

                    // Row background: current week full highlight, next week subtle
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color:   Kirigami.Theme.highlightColor
                        opacity: weekRow.isCurrent ? 0.10 : weekRow.isNext ? 0.04 : 0
                    }

                    // Past week dim overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color:   Kirigami.Theme.backgroundColor
                        opacity: weekRow.isPast ? 0.45 : 0
                    }

                    // Bottom separator
                    Rectangle {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.bottom: parent.bottom
                        height:  1
                        color:   Kirigami.Theme.textColor
                        opacity: 0.12
                    }

                    // Layer 1 — day cells
                    RowLayout {
                        anchors.fill: parent
                        spacing: cellGap

                        Repeater {
                            model: 7
                            delegate: Item {
                                Layout.fillWidth:  true
                                Layout.fillHeight: true

                                readonly property var  date:      cellDate(weekRow.weekIdx, index)
                                readonly property bool todayCell: isToday(date)
                                readonly property bool curMonth:  isCurrentMonth(date)

                                // Today: full cell highlight
                                Rectangle {
                                    visible: todayCell
                                    anchors.fill:    parent
                                    anchors.margins: 1
                                    radius:  4
                                    color:   Kirigami.Theme.highlightColor
                                    opacity: 0.20
                                }

                                Text {
                                    anchors.top:         parent.top
                                    anchors.right:       parent.right
                                    anchors.topMargin:   3
                                    anchors.rightMargin: 5
                                    text:           date.getDate()
                                    font.pixelSize: 13
                                    font.bold:      todayCell
                                    color:          todayCell ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                                    opacity:        curMonth ? 1.0 : 0.4
                                }

                                Text {
                                    visible: date.getDate() === 1
                                    anchors.top:        parent.top
                                    anchors.left:       parent.left
                                    anchors.topMargin:  3
                                    anchors.leftMargin: 5
                                    text:           Qt.formatDate(date, "MMM")
                                    font.pixelSize: 10
                                    color:          Kirigami.Theme.textColor
                                    opacity:        0.5
                                }
                            }
                        }
                    }

                    // Layer 2 — event bars
                    Item {
                        id: overlay
                        anchors.fill: parent

                        Repeater {
                            model: weekRow.weekEvs
                            delegate: Item {
                                readonly property var   ev:         modelData
                                readonly property real  cellW:      (overlay.width - cellGap * 6) / 7
                                readonly property real  barX:       ev.startCol * (cellW + cellGap)
                                readonly property real  barW:       ev.spanCols * cellW + (ev.spanCols - 1) * cellGap
                                readonly property real  barY:       weekRow.dynBarTopOffset + ev.lane * (weekRow.dynBarH + barGap)
                                readonly property color barColor:   seriesColor(ev.series)
                                readonly property color labelColor: contrastColor(seriesColor(ev.series))

                                x:       barX
                                y:       barY
                                width:   barW
                                height:  weekRow.dynBarH
                                visible: barY + weekRow.dynBarH <= weekRow.height

                                Rectangle {
                                    anchors.fill: parent
                                    color:  barColor
                                    radius: 3
                                    topLeftRadius:     ev.clippedLeft  ? 0 : 3
                                    bottomLeftRadius:  ev.clippedLeft  ? 0 : 3
                                    topRightRadius:    ev.clippedRight ? 0 : 3
                                    bottomRightRadius: ev.clippedRight ? 0 : 3
                                }

                                Text {
                                    visible: ev.clippedLeft
                                    anchors.left:           parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin:     1
                                    text: "◀"
                                    font.pixelSize: 8
                                    color: labelColor
                                }
                                Text {
                                    visible: ev.clippedRight
                                    anchors.right:          parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin:    1
                                    text: "▶"
                                    font.pixelSize: 8
                                    color: labelColor
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left:           parent.left
                                    anchors.right:          parent.right
                                    anchors.leftMargin:     ev.clippedLeft  ? 12 : 4
                                    anchors.rightMargin:    ev.clippedRight ? 12 : 4
                                    clip:  true
                                    elide: Text.ElideRight
                                    font.pixelSize: weekRow.dynFontPx
                                    font.bold: true
                                    color: labelColor
                                    text: barW > 160 ? ev.flag + " " + ev.location + " | " + ev.eventType
                                        : barW > 72  ? ev.flag + " " + ev.location
                                        : barW > 28  ? ev.flag
                                        :              ""
                                }
                            }
                        }
                    }
                }
            }

            // ── ▼ Next week ───────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: navH
                radius: 4
                color: nextArea.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                opacity: nextArea.containsMouse ? 0.5 : 0.6

                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    font.pixelSize: 13
                    color: Kirigami.Theme.textColor
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: weekOffset++
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Mouse wheel scrolling
        WheelHandler {
            onWheel: function(event) {
                weekOffset += event.angleDelta.y < 0 ? 1 : -1
            }
        }
    }
}
