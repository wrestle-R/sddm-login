import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1200
    color: "#102338"
    // Injectable only for the isolated native preview. SDDM supplies these objects.
    property var authBackend: sddm
    property var users: userModel
    property var sessions: sessionModel
    property date now: new Date()
    property bool submitting: false
    property bool loginError: false
    property bool frameSeen: false
    property bool entryQueued: false
    property real introOpacity: 1
    property real landscapeScale: 1.025
    property real clockOpacity: 0
    property real haloOpacity: 0
    property real haloRotation: -7
    property real formOpacity: 0
    property real formOffset: 18
    property real detailsOpacity: 0
    property string notice: ""
    readonly property color ink: "#f8ead7"
    readonly property color muted: "#c9cdd0"
    readonly property color accent: "#f1c893"
    readonly property real fit: Math.min(width / 1600, height / 1000)
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    function login() {
        if (submitting) return;
        if (!username.text.trim()) { notice = "Enter your username."; username.forceActiveFocus(); return; }
        if (session.currentIndex < 0) { notice = "No session available."; session.forceActiveFocus(); return; }
        submitting = true;
        reveal.checked = false;
        loginError = false;
        notice = "Signing in…";
        // Authentication never waits for animation timers or frame delivery.
        root.authBackend.login(username.text.trim(), password.text, session.currentIndex);
    }
    Component.onCompleted: Qt.callLater(function() {
        if (username.text.length) password.forceActiveFocus(); else username.forceActiveFocus();
    })

    Image { anchors.fill: parent; source: "wallpaper.jpg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: "transparent" } GradientStop { position: 0.65; color: "#1011263b" } GradientStop { position: 1; color: "#90102338" } } }
    Item {
        id: stage
        width: 1600; height: 1000
        anchors.centerIn: parent
        scale: root.fit
        transformOrigin: Item.Center
        Canvas {
            id: clockFace
            x: 945; y: 165; width: 565; height: 115
            property string timeText: Qt.formatDateTime(root.now, "hhmm")
            onTimeTextChanged: requestPaint()
            onPaint: {
                const c=getContext("2d"); c.reset(); c.fillStyle="#183247";
                const maps=["111101101101111","010110010010111","111001111100111","111001111001111","101101111001001","111100111001111","111100111101111","111001001001001","111101111101111","111101111001111"];
                const unit=height/5;
                for(let n=0;n<4;n++) {
                    const digit=Number(timeText[n]); const x=n*width/4;
                    if(digit===1) { c.fillRect(x+unit,0,unit,unit*4); c.fillRect(x,unit*4,unit*3,unit); c.fillRect(x,0,unit,unit); }
                    else if(digit===4) { c.fillRect(x,0,unit,unit*2); c.fillRect(x,unit*2,unit*3,unit); c.fillRect(x+unit*2,0,unit,unit*5); }
                    else { const map=maps[digit]; for(let i=0;i<15;i++) if(map[i]==="1") c.fillRect(x+(i%3)*unit,Math.floor(i/3)*unit,unit,unit); }
                }
            }
        }
        Text { x: 945; y: 310; width: 540; text: Qt.formatDateTime(root.now,"dddd, d MMMM"); color: "#183247"; font.family: "Noto Sans"; font.pixelSize: 27; horizontalAlignment: Text.AlignRight }
        Item {
            id: auth
            objectName: "authControls"
            x: 1025; y: 560; width: 460; height: 270
            opacity: 1
            
            StrokeIcon { x: 427; y: 18; width: 19; height: 19; glyph: "down"; ink: root.ink }
            TextField {
                id: username
                objectName: "usernameField"
                x: 0; y: 0; width: 460; height: 55
                text: root.users.lastUser || ""
                placeholderText: "Username"
                color: root.muted
                placeholderTextColor: root.muted
                selectionColor: root.ink
                selectedTextColor: "#172838"
                font.family: "Noto Sans"; font.pixelSize: 27
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 0; rightPadding: 48
                enabled: !root.submitting
                background: Rectangle { radius: 16; color: username.activeFocus ? "#45142334" : "transparent"; border.width: username.activeFocus ? 1 : 0; border.color: root.ink }
                onAccepted: password.forceActiveFocus()
                Accessible.name: "Username"
                KeyNavigation.tab: password
            }
            TextField {
                id: password
                objectName: "passwordField"
                x: 0; y: 90; width: 460; height: 58
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                placeholderText: "Password"
                placeholderTextColor: "#d1c7b9"
                color: root.ink
                selectionColor: root.ink
                selectedTextColor: "#172838"
                font.family: "Noto Sans"; font.pixelSize: 17
                leftPadding: 0; rightPadding: 100
                enabled: !root.submitting
                onAccepted: root.login()
                Keys.onEscapePressed: clear()
                KeyNavigation.tab: reveal
                Accessible.name: "Password"
                background: Rectangle { color: "transparent"; Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.loginError ? "#ffb4a6" : password.activeFocus ? "#fff3df" : "#a0e0e8e7" } }
                Button {
                    id: reveal
                    x: parent.width - width - 54; anchors.verticalCenter: parent.verticalCenter
                    width: 38; height: 38
                    enabled: !root.submitting
                    checkable: true
                    onToggled: password.echoMode = checked ? TextInput.Normal : TextInput.Password
                    KeyNavigation.tab: signIn
                    Accessible.name: checked ? "Hide password" : "Show password"
                    contentItem: StrokeIcon { glyph: "eye"; ink: root.ink }
                    padding: 8
                    background: Rectangle { radius: 19; color: reveal.hovered || reveal.activeFocus ? "#25f1c893" : "transparent"; border.width: reveal.activeFocus ? 1 : 0; border.color: root.ink }
                }
            }
            Button {
                id: signIn
                objectName: "signInButton"
                x: 412; y: 90; width: 48; height: 58
                enabled: !root.submitting
                Accessible.name: "Sign in"
                KeyNavigation.tab: session
                onClicked: root.login()
                scale: down ? 0.95 : hovered ? 1.035 : 1
                Behavior on scale { NumberAnimation { duration: 140 } }
                contentItem: StrokeIcon { glyph: "arrow"; ink: root.ink }
                padding: 18
                background: Rectangle { color: signIn.activeFocus || signIn.hovered ? "#25ffffff" : "transparent"; radius: 4 }
            }
            ComboBox {
                id: session
                objectName: "sessionPicker"
                x: 0; y: 167; width: 460; height: 55
                model: root.sessions
                textRole: "name"
                currentIndex: root.sessions.lastIndex >= 0 ? root.sessions.lastIndex : 0
                enabled: !root.submitting
                leftPadding: 0; rightPadding: 48
                KeyNavigation.tab: sleepButton.visible ? sleepButton : restartButton.visible ? restartButton : powerButton
                Accessible.name: "Session"
                contentItem: Text { text: session.displayText; color: root.ink; font.family: "Noto Sans"; font.pixelSize: 17; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                indicator: StrokeIcon { x: session.width-width-14; anchors.verticalCenter: parent.verticalCenter; width: 19; height: 19; glyph: "down"; ink: root.ink }
                background: Rectangle { color: session.activeFocus ? "#20ffffff" : "transparent"; radius: 4 }
                delegate: ItemDelegate {
                    required property var model
                    required property int index
                    width: session.width - 10
                    highlighted: session.highlightedIndex === index
                    contentItem: Text { text: parent.model.name; color: root.ink; font.family: "Noto Sans"; font.pixelSize: 16; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { radius: 16; color: parent.highlighted ? "#3f5361" : "transparent" }
                }
                popup: Popup {
                    y: session.height + 8; width: session.width; padding: 5
                    implicitHeight: Math.min(contentItem.implicitHeight + 10, 210)
                    contentItem: ListView { clip: true; implicitHeight: contentHeight; model: session.popup.visible ? session.delegateModel : null; currentIndex: session.highlightedIndex; ScrollIndicator.vertical: ScrollIndicator {} }
                    background: Rectangle { radius: 21; color: "#ef162b3e"; border.width: 1; border.color: "#9aab9c87" }
                }
            }
            Text {
                id: message
                objectName: "authMessage"
                x: 0; y: 225; width: 460; height: 40
                text: root.notice
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: root.loginError ? "#ffd0be" : root.muted
                font.family: "Noto Sans"; font.pixelSize: 27
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Accessible.role: Accessible.AlertMessage
            }
        }
        Row {
            x: 1025; y: 895
            spacing: 12
            opacity: 1
            QuietButton { id: sleepButton; text: "Sleep"; glyph: "moon"; visible: root.authBackend.canSuspend; onClicked: root.authBackend.suspend(); KeyNavigation.tab: restartButton.visible ? restartButton : powerButton }
            QuietButton { id: restartButton; text: "Restart"; glyph: "restart"; visible: root.authBackend.canReboot; onClicked: root.authBackend.reboot(); KeyNavigation.tab: powerButton.visible ? powerButton : username }
            QuietButton { id: powerButton; text: "Shut down"; glyph: "power"; visible: root.authBackend.canPowerOff; onClicked: root.authBackend.powerOff(); KeyNavigation.tab: username }
        }
    }
    Connections {
        target: root.authBackend
        function onLoginFailed() {
            root.submitting = false;
            root.loginError = true;
            password.clear();
            reveal.checked = false;
            root.notice = "Sign-in failed. Please try again.";
            password.forceActiveFocus();
        }
        function onLoginSucceeded() { password.clear(); reveal.checked = false; root.notice = ""; }
        function onInformationMessage(text) { root.notice = text; }
    }
    component QuietButton: Button {
        id: control
        property string glyph
        implicitWidth: text === "Shut down" ? 160 : 145
        implicitHeight: 45
        padding: 10
        scale: down ? 0.975 : 1
        Behavior on scale { NumberAnimation { duration: 120 } }
        contentItem: RowLayout {
            spacing: 11
            StrokeIcon { width: 19; height: 19; glyph: control.glyph; ink: root.ink }
            Text { text: control.text; color: root.ink; font.family: "Noto Sans"; font.pixelSize: 14; verticalAlignment: Text.AlignVCenter }
        }
        background: Rectangle { radius: height / 2; color: control.hovered ? "#663c4c58" : "#25102437"; border.width: 1; border.color: control.activeFocus ? root.ink : "#708a8b88"; Behavior on color { ColorAnimation { duration: 160 } } }
    }
    component HaloArc: Canvas {
        property bool lower: false
        onPaint: {
            const c = getContext("2d");
            c.reset();
            const count = 150;
            const cx = lower ? 277 : 291, cy = lower ? 206 : 265;
            const start = lower ? -0.08 : -3.08, span = lower ? 1.52 : 1.67;
            for (let i = 0; i < count; i++) {
                const t = i / count, a = start + span * t;
                const alpha = Math.pow(Math.sin(Math.PI * t), 2);
                for (const layer of [{w:15,a:0.06},{w:7,a:0.16},{w:2.5,a:0.55},{w:1.1,a:1}]) {
                    // Use a short elliptical arc; the faint wide strokes supply the glow.
                    c.beginPath();
                    c.moveTo(cx + 257*Math.cos(a), cy + 205*Math.sin(a));
                    const b = start + span*(i+1.4)/count;
                    c.lineTo(cx + 257*Math.cos(b), cy + 205*Math.sin(b));
                    c.strokeStyle = "rgba(255,213,163," + alpha*layer.a + ")";
                    c.lineWidth = layer.w;
                    c.lineCap = "round";
                    c.stroke();
                }
            }
        }
    }
    component StrokeIcon: Canvas {
        property string glyph
        property color ink: "white"
        onInkChanged: requestPaint()
        onGlyphChanged: requestPaint()
        onPaint: {
            const c=getContext("2d"); c.reset(); c.scale(width/24,height/24);
            c.strokeStyle=ink; c.lineWidth=1.7; c.lineCap="round"; c.lineJoin="round"; c.beginPath();
            if (glyph==="power") { c.moveTo(12,3);c.lineTo(12,12);c.moveTo(6,6);c.bezierCurveTo(-2,13,4,22,12,22);c.bezierCurveTo(21,22,26,13,18,6); }
            else if(glyph==="restart") { c.arc(12,13,8,-0.8,4.5);c.moveTo(20,4);c.lineTo(20,10);c.lineTo(14,10); }
            else if(glyph==="moon") { c.moveTo(16,3);c.bezierCurveTo(3,-1,-2,17,10,21);c.bezierCurveTo(17,24,23,18,22,13);c.bezierCurveTo(14,17,9,9,16,3); }
            else if(glyph==="lock") { c.rect(5,10,14,11);c.moveTo(8,10);c.lineTo(8,7);c.bezierCurveTo(8,1,16,1,16,7);c.lineTo(16,10);c.moveTo(12,14);c.lineTo(12,17); }
            else if(glyph==="eye") { c.moveTo(2,12);c.quadraticCurveTo(12,1,22,12);c.quadraticCurveTo(12,23,2,12);c.moveTo(15,12);c.arc(12,12,3,0,2*Math.PI); }
            else if(glyph==="arrow") { c.moveTo(3,12);c.lineTo(21,12);c.moveTo(14,5);c.lineTo(21,12);c.lineTo(14,19); }
            else if(glyph==="layers") { c.moveTo(2,8);c.lineTo(12,3);c.lineTo(22,8);c.lineTo(12,13);c.closePath();c.moveTo(2,12);c.lineTo(12,17);c.lineTo(22,12);c.moveTo(2,16);c.lineTo(12,21);c.lineTo(22,16); }
            else { c.moveTo(6,9);c.lineTo(12,15);c.lineTo(18,9); }
            c.stroke();
        }
    }
}
