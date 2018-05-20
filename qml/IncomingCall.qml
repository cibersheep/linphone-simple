/*
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
 
import Linphone 1.0

PopupBase {
    id: incomingCall

    readonly property string defaultColor: "#eb6536"
    property string callColor: "#eb6536"
    //property alias color: shape.color
    
    property int duration: 0

    Rectangle {
        anchors.fill: parent
        Column {
			width: parent.width
			anchors.top: parent.top
			anchors.topMargin: units.gu(10)
			
			spacing: units.gu(4)
			Label {
				id: notice
				anchors.horizontalCenter: parent.horizontalCenter
				text: "Incoming Call"
			}
			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				text: showId
				textSize: Label.Large
				font.bold: true
			}
			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				text: showDomain
				textSize: Label.Large
			}
			Label {
				id: durationCallTime
				anchors.horizontalCenter: parent.horizontalCenter
				text: "Duration: " + duration + " seconds"
			}
			
        }
	
		Row {
			//width: parent.width
			anchors.bottom: parent.bottom
			anchors.bottomMargin: units.gu(10)
			spacing: units.gu(4)
			anchors.horizontalCenter: parent.horizontalCenter
			UbuntuShape {
				id: answerCall

				width: units.gu(15)
				height: units.gu(5)
				
				color: UbuntuColors.green
				radius: "medium"
				
				opacity: pressArea.pressed ? 0.5 : 1

				Behavior on opacity {
					UbuntuNumberAnimation { }
				}
				
				Icon {
					id: icon
					anchors.centerIn: parent
					width: units.gu(3)
					height: units.gu(3)
					name: "call-start"
					color: "white"
					asynchronous: true
					z: 1
				}
				
				MouseArea {
					id: pressArea
					anchors.fill: parent
					onClicked: {
						console.log("Answer Incoming Call")
						Linphone.answer()
						notice.text = "Current Call"
					}
				}

			}


			UbuntuShape {
				id: hangUp

				width: units.gu(15)
				height: units.gu(5)
				
				color: UbuntuColors.red
				radius: "medium"
				
				opacity: pressArea2.pressed ? 0.5 : 1

				Behavior on opacity {
					UbuntuNumberAnimation { }
				}
				
				Icon {
					id: icon2
					anchors.centerIn: parent
					width: units.gu(3)
					height: units.gu(3)
					name: "call-start"
					color: "white"
					asynchronous: true
					z: 1
					rotation: 225
				}
				
				MouseArea {
					id: pressArea2
					anchors.fill: parent
					onClicked: {
						console.log("Hang up and close popup")
						Linphone.terminate()
						closingPop()
					}
				}

			}
		}
		   

    }
    Timer {
		id: inCall
		repeat: true
		onTriggered: {
			duration += 1
			Linphone.command(["generic","calls"])
			
			//TODO: Do a more elegant way of detect the status report onReadStatus
			console.log("Label: " + infoLabel.text)
			if (!pageTest.incomingCall) {
				closingPop()
			}
		}
    }
    
    function closingPop() {
		console.log("ClosingPop triggered")
		inCall.stop()
		incomingCall.hide()
		duration = 0
    }
    Component.onCompleted: {
		pageTest.incomingCall = true
		inCall.start()
        show()
    }
    Component.onDestruction: {
		//To be used when PopupBase is closed
		console.log("Popup destroyed")
    }
}
