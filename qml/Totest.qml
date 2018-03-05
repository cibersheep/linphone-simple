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

import ServiceControl 1.0
import Linphone 1.0

Page {
    id: pageTest
    //Component.onCompleted: linphone.run()

    property bool applicationActive: Qt.application.active
    property string ussdResponseTitle: ""
    property string ussdResponseText: ""
    property bool greeterMode: (state == "greeterMode")
    property bool telepathyReady: false
    property bool onCall: false
    property var currentStack: mainView.greeterMode ? pageStackGreeterMode : pageStackNormalMode
    property var bottomEdge: null
    property int iconRotation

    //automaticOrientation: false
    implicitWidth: units.gu(40)
    implicitHeight: units.gu(71)

    //property bool hasCalls: callManager.hasCalls

    property string pendingNumberToDial: ""
    property bool accountReady: false
	    
	header: PageHeader {visible: false}
	Flickable {
		anchors.fill: parent
		height: mainCol.height + units.gu(40)
		Column { 
			id: mainCol
			width: parent.width
			anchors.top: parent.top
			//anchors.topMargin: units.gu(3)
			spacing: units.gu(2.5)
			Label {
				id: infoLabel
				width: parent.width
				text: "Doing nothing"
			}

			TextField {
				id: sipCall
				width: parent.width-units.gu(3)
				placeholderText: "SIP address. No `sip:` nor `:5060`"
				anchors.horizontalCenter: parent.horizontalCenter
				inputMethodHints: Qt.ImhUrlCharactersOnly
			}
			Button {
				text: "@sip.linphone.org"
				onClicked: sipCall.text += "@sip.linphone.org"
				anchors.horizontalCenter: parent.horizontalCenter
			}
			Button {
				text: "@sip.ippi.com"
				onClicked: sipCall.text += "@sip.ippi.com"
				anchors.horizontalCenter: parent.horizontalCenter
			}
			Button {
				text: "@callcentric.com"
				onClicked: sipCall.text += "@callcentric.com"
				anchors.horizontalCenter: parent.horizontalCenter
			}

			CallButton {
				id: callButton
				objectName: "callButton"
				enabled: sipCall.text==="" ? false : true //mainView.telepathyReady
				anchors.horizontalCenter: parent.horizontalCenter
				
				onClicked: {
					onCall = !onCall
					onCall ? iconRotation = 225 : iconRotation = 0
					onCall ? callColor = UbuntuColors.red : callColor = defaultColor
					onCall ? console.log("Try to call to " + sipCall.text) : console.log("Hanging up")
					onCall ? Linphone.call("sip:" + sipCall.text + ":5060") : Linphone.terminate()
				}
			}
			TextField {
				id: user
				width: parent.width-units.gu(3)
				placeholderText: "Username"
				anchors.horizontalCenter: parent.horizontalCenter
				inputMethodHints: Qt.ImhUrlCharactersOnly
			}
			TextField {
				id: domain
				width: parent.width-units.gu(3)
				placeholderText: "SIP host"
				anchors.horizontalCenter: parent.horizontalCenter
				inputMethodHints: Qt.ImhUrlCharactersOnly
			}
			TextField {
				id: password
				width: parent.width-units.gu(3)
				placeholderText: "Password"
				anchors.horizontalCenter: parent.horizontalCenter
				inputMethodHints: Qt.ImhUrlCharactersOnly
				echoMode: TextInput.Password
			}
			Button {
				text: "login"
				onClicked: {
					console.log("Registering " + user)
					Linphone.registerSIP(user.text, domain.text, password.text)
				}
			}
		}
	}
}
