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

import ServiceControl 1.0
import Linphone 1.0

Page {
    id: pageTest
    //Component.onCompleted: linphone.run()

    property bool applicationActive: Qt.application.active
    property string ussdResponseTitle: ""
    property string ussdResponseText: ""
    property string statusTextReceived: ""
    property bool greeterMode: (state == "greeterMode")
    property bool telepathyReady: false
    property bool onCall: false
    property bool incomingCall: false
    property var currentStack: mainView.greeterMode ? pageStackGreeterMode : pageStackNormalMode
    property var bottomEdge: null
    property int iconRotation
    
    property string showId: ""
    property string showDomain: ""

    //automaticOrientation: false
    implicitWidth: units.gu(40)
    implicitHeight: units.gu(71)

    //property bool hasCalls: callManager.hasCalls

    property string pendingNumberToDial: ""
    property bool accountReady: false
	    
	header: PageHeader {visible: false}
		
    Component.onCompleted: {
		//Check if opened the app because we have an incoming call
		if (args.values.url && args.values.url.match(/^linphone/)) {
			console.log("Incomin Call Closed App")
            showIncomingCall(args.values.url);
		} else if (Qt.application.arguments && Qt.application.arguments.length > 0) {
            for (var i = 0; i < Qt.application.arguments.length; i++) {
                if (Qt.application.arguments[i].match(/^linphone/)) {
                    showIncomingCall(Qt.application.arguments[i]);
                }
            }
	}
		
		//Get the first Registering Status
		Linphone.status("register")
		
    }
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
				text: "No registration information"
				Connections {
					target: Linphone
					onReadStatus: { 
						statusTextReceived = Linphone.readStatusOutput() 
						infoLabel.text = statusTextReceived.trim()
						if (statusTextReceived.trim().slice(0,14) === "No active call") {
							console.log("Received: No acive calls")
							incomingCall = false
						}
					}
				}
			}

			TextField {
				id: sipCall
				width: parent.width-units.gu(3)
				placeholderText: "SIP address to call"
				anchors.horizontalCenter: parent.horizontalCenter
				inputMethodHints: Qt.ImhUrlCharactersOnly
			}
			Row {
				Button {
					text: "@sip.linphone.org"
					onClicked: sipCall.text += "@sip.linphone.org"
					//anchors.horizontalCenter: parent.horizontalCenter
				}
				Button {
					text: "@sip.ippi.com"
					onClicked: sipCall.text += "@sip.ippi.com"
					//anchors.horizontalCenter: parent.horizontalCenter
				}
				Button {
					text: "@callcentric.com"
					onClicked: sipCall.text += "@callcentric.com"
					//anchors.horizontalCenter: parent.horizontalCenter
				}
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
					//Replace 'sip:' 'http(s):' '/' ':number'
					onCall ? Linphone.call("sip:" + sipCall.text.replace(/sip\:|\:(\d+)|https\:|http\:|\//gi,"") + ":5060") : Linphone.terminate()
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
			Row {
				spacing: units.gu(2)
				Button {
					text: "login"
					onClicked: {
						console.log("Registering " + user)
						Linphone.registerSIP(user.text, domain.text, password.text)
					}
				}
				Button {
					text: "Register Status"
					onClicked: {
						Linphone.status("register")
					}
				}
			}
			Row {
				spacing: units.gu(2)
				Button {
					text: "Answer"
					onClicked: {
						Linphone.answer()
					}
				}
				Button {
					text: "Hangup"
					onClicked: {
						Linphone.terminate()
					}
				}
				
			}
			
			Row {
				width: parent.width
				spacing: units.gu(1)
				TextField {
					id: command
					width: parent.width - buttonSend.width - units.gu(1)
					placeholderText: "Send a command to Linphone"
					//anchors.horizontalCenter: parent.horizontalCenter
					inputMethodHints: Qt.ImhUrlCharactersOnly
					onAccepted: buttonSend.clicked()
				}
				Button {
					id: buttonSend
					text: ">"
					onClicked: {
						Linphone.command(command.text.split(" "))
					}
				}
			}
			
		}
	}
	
	Arguments {
        id: args

        Argument {
            name: 'url'
            help: i18n.tr('Incoming Call from URL')
            required: false
            valueNames: ['URL']
        }
	}

	Connections {
        target: UriHandler
        onOpened: {
			console.log('Open from UriHandler')
            if (uris.length > 0) {
                console.log('Incoming call from UriHandler ' + uris[0]);
                showIncomingCall(uris[0]);
            }
        }
	}
	
	Component {
		id: incomingCallComponent

		IncomingCall {
			anchors.fill: parent
		}
	}
	function showIncomingCall(callerId) {
		showId = callerId.replace("linphone://incoming/sip:","").split("@")[0]
		showDomain = callerId.replace(":5060","").split("@")[1]
		console.log("ID name: "+showId)
		PopupUtils.open(incomingCallComponent);
	}
}
