/*
 * Copyright 2012-2016 Canonical Ltd.
 *
 * This file is part of dialer-app.
 *
 * dialer-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * dialer-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

import ServiceControl 1.0
import Linphone 1.0

//import "../"

Page {
    id: page

    property alias dialNumber: keypadEntry.value
    property alias input: keypadEntry.input
    property alias callAnimationRunning: callAnimation.running
    property bool greeterMode: false
    readonly property bool compactView: page.height <= units.gu(60)
    property bool connected: false

    function selectAccount(accountId) {
		console.log("SelectAccount called")
    }

    header: PageHeader {
        id: pageHeader

        property list<Action> actionsGreeter
        property list<Action> actionsNormal: [
            Action {
                iconName: "settings"
                text: i18n.tr("Settings")
                //onTriggered: pageStackNormalMode.push(Qt.resolvedUrl("../SettingsPage/SettingsPage.qml"))
            },
            Action {
                objectName: "contacts"
                iconName: "contact"
                text: i18n.tr("Contacts")
                //onTriggered: pageStackNormalMode.push(Qt.resolvedUrl("../ContactsPage/ContactsPage.qml"))
            },
            Action {
                objectName: "message"
                iconName: "message"
                text: i18n.tr("Messages")
                //onTriggered: pageStackNormalMode.push(Qt.resolvedUrl("../ContactsPage/ContactsPage.qml"))
            },
            Action {
                objectName: "dialer-app-symbolic"
                iconName: "dialer"
                text: i18n.tr("Dialer")
                //onTriggered: pageStackNormalMode.push(Qt.resolvedUrl("../ContactsPage/ContactsPage.qml"))
            }
            

        ]
        title: page.title
        focus: false
        trailingActionBar {
            actions: actionsNormal
            numberOfSlots: 4
        }


        leadingActionBar {
            property list<QtObject> backActionList: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Close")
                    visible: mainView.greeterMode
                    onTriggered: {
                        greeter.showGreeter()
                        dialNumber = "";
                    }
                }
            ]
            property list<QtObject> simLockedActionList: [
                Action {
                    id: simLockedAction
                    objectName: "simLockedAction"
                    iconName: "simcard-locked"
                    onTriggered: {
                        mainView.showSimLockedDialog()
                    }
                }
            ]
            actions: {
                if (mainView.simLocked) {
                    return simLockedActionList
                } else {
                    return backActionList
                }
            }
        }

        //extension: headerSections.model.length > 1 ? headerSections : null
    }

    objectName: "dialerPage"
    title: i18n.tr("Phone")

    state: mainView.state
    // -------- Greeter mode ----------
    states: [
        State {
            name: "greeterMode"
            PropertyChanges {
                target: contactLabel
                visible: false
            }
            PropertyChanges {
                target: addContact
                visible: false
            }
        },
        State {
            name: "normalMode"
            PropertyChanges {
                target: contactLabel
                visible: true
            }
            PropertyChanges {
                target: addContact
                visible: true
            }
        }
    ]

    // Forward key presses
    Keys.onPressed: {
        if (!active) {
            return
        }

        // in case Enter is pressed, remove focus from the view to prevent multiple calls to get placed
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            page.focus = false;
        }

        keypad.keyPressed(event.key, event.text)
    }

    function triggerCallAnimation() {
        callAnimation.start();
    }

    Connections {
        target: mainView
        onPendingNumberToDialChanged: {
            keypadEntry.value = mainView.pendingNumberToDial;
            if (mainView.pendingNumberToDial !== "") {
                mainView.switchToKeypadView();
            }
        }
    }

    function createObjectAsynchronously(componentFile, callback) {
        var component = Qt.createComponent(componentFile, Component.Asynchronous);

        function componentCreated() {
            if (component.status == Component.Ready) {
                var incubator = component.incubateObject(page, {}, Qt.Asynchronous);

                function objectCreated(status) {
                    if (status == Component.Ready) {
                        callback(incubator.object);
                    }
                }
                incubator.onStatusChanged = objectCreated;

            } else if (component.status == Component.Error) {
                console.log("Error loading component:", component.errorString());
            }
        }

        component.statusChanged.connect(componentCreated);
    }

    function pushMmiPlugin(plugin) {
        mmiPlugins.push(plugin);
    }

    Component.onCompleted: {
        
    }


    // background
    Rectangle {
        anchors.fill: parent
        color: Theme.palette.normal.background
    }
    Rectangle {
        id: accountConnected
        anchors.top: pageHeader.bottom
        height: units.gu(4)
        width: parent.width
        //color: UbuntuColors.silk
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: units.gu(2)
            spacing: units.gu(2)
            Icon {
                width: units.gu(2.5)
                height: width
                name: "media-record"
                color: connected ? UbuntuColors.green : UbuntuColors.red
            }
            Label {
                text: "Here goes the account name"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

    }
    ListItems.ThinDivider {
        id: divider2

        anchors {
            top: accountConnected.bottom
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            //bottom: keypadContainer.top
        }
    }
    FocusScope {
        id: keypadContainer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: footer.top
            topMargin: pageHeader.height + accountConnected.height
        }
        focus: true

        Item {
            id: entryWithButtons

            anchors {
                top: parent.top
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
            }
            height: page.compactView ? units.gu(7) : units.gu(10)

            CustomButton {
                id: addContact

                anchors {
                    left: parent.left
                    verticalCenter: keypadEntry.verticalCenter
                }
                width: opacity > 0 ? (page.compactView ? units.gu(4) : units.gu(3)) : 0
                height: (keypadEntry.value !== "" ) ? parent.height : 0
                icon: "contact-new"
                iconWidth: units.gu(3)
                iconHeight: units.gu(3)
                opacity: (keypadEntry.value !== "" && contactWatcher.isUnknown) ? 1.0 : 0.0

                Behavior on opacity {
                    UbuntuNumberAnimation { }
                }

                Behavior on width {
                    UbuntuNumberAnimation { }
                }

                onClicked: mainView.addNewPhone(keypadEntry.value)
            }

            KeypadEntry {
                id: keypadEntry
                objectName: "keypadEntry"

                anchors {
                    top: parent.top
                    topMargin: units.gu(3)
                    left: addContact.right
                    right: backspace.left
                }
                focus: true
                placeHolder: i18n.tr("Enter a number")
                Keys.forwardTo: [callButton]
                value: mainView.pendingNumberToDial
                height: page.compactView ? units.gu(2) : units.gu(4)
                maximumFontSize: page.compactView ? units.dp(20) : units.dp(30)
                onCommitRequested: {
                    callButton.clicked()
                }
            }
            

            CustomButton {
                id: backspace
                objectName: "eraseButton"
                anchors {
                    right: parent.right
                    verticalCenter: keypadEntry.verticalCenter
                }
                width: opacity > 0 ? (page.compactView ? units.gu(4) : units.gu(3)) : 0
                height: input.text !== "" ? parent.height : 0
                icon: "erase"
                iconWidth: units.gu(3)
                iconHeight: units.gu(3)
                opacity: input.text !== "" ? 1 : 0

                Behavior on opacity {
                    UbuntuNumberAnimation { }
                }

                Behavior on width {
                    UbuntuNumberAnimation { }
                }

                onPressAndHold: input.text = ""

                onClicked:  {
					//Implement a real clear ONE number
                    input.text = ""
                }
            }
        }

        ListItems.ThinDivider {
            id: divider

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
                top: entryWithButtons.bottom
            }
        }


        Label {
            id: contactLabel
            anchors {
                horizontalCenter: divider.horizontalCenter
                bottom: entryWithButtons.bottom
                bottomMargin: units.gu(1)
            }
            text: ""
            color: UbuntuColors.darkGrey
            opacity: text != "" ? 1 : 0
            fontSize: "small"
            Behavior on opacity {
                UbuntuNumberAnimation { }
            }
        }

        Keypad {
            id: keypad
            showVoicemail: true

            anchors {
                top: divider.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(2)
            }
            labelPixelSize: page.compactView ? units.dp(20) : units.dp(30)
            spacing: page.compactView ? 0 : 5
            onKeyPressed: {
                // handle special keys (backspace, arrows, etc)
                keypadEntry.handleKeyEvent(keycode, keychar)

                if (keycode == Qt.Key_Space) {
                    return
                }

                input.text += keychar

            }
            onKeyPressAndHold: {
                // we should only call voicemail if the keypad entry was empty,
                // but as we add numbers when onKeyPressed is triggered, the keypad entry will be "1"
                if (keycode == Qt.Key_1 && dialNumber == "1") {
                    dialNumber = ""
                    mainView.callVoicemail()
                } else if (keycode == Qt.Key_0) {
                    // replace 0 by +
                    console.log("Implement a replace 00 for +")
                    //input.remove(input.cursorPosition - 1, input.cursorPosition)
                    //input.insert(input.cursorPosition, "+")
                }
            }
        }
    }

    Item {
        id: footer

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(10)

        CallButton {
            id: callButton
            objectName: "callButton"
            enabled: input.text==="" ? false : true //mainView.telepathyReady
            anchors {
                bottom: footer.bottom
                bottomMargin: units.gu(5)
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                if (dialNumber == "") {
                    if (mainView.greeterMode) {
                        return;
                    }
                    keypadEntry.value = generalSettings.lastCalledPhoneNumber
                    return;
                }


                //console.log("Starting a call to " + keypadEntry.value);
                //mainView.call(keypadEntry.value);
                console.log("Starting a call to cibersheep@sip.linphone.org");
                Linphone.call("sip:cibersheep@linphone.org:5060");
            }
        }
    }

    SequentialAnimation {
        id: callAnimation

        PropertyAction {
            target: callButton
            property: "color"
            value: "red"
        }

        ParallelAnimation {
            UbuntuNumberAnimation {
                target: keypadContainer
                property: "opacity"
                to: 0.0
                duration: UbuntuAnimation.SlowDuration
            }
            UbuntuNumberAnimation {
                target: callButton
                property: "iconRotation"
                to: -90.0
                duration: UbuntuAnimation.SlowDuration
            }
        }
        ScriptAction {
            script: {
                mainView.switchToLiveCall(i18n.tr("Calling"), keypadEntry.value)
                keypadEntry.value = ""
                callButton.iconRotation = 0.0
                keypadContainer.opacity = 1.0
                callButton.color = callButton.defaultColor
            }
        }
    }

    
}
